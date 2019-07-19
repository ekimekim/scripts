import functools
import itertools
import sys
from collections import namedtuple

import argh
from ipaddress import IPv4Network

import easycmd


pair = namedtuple('pair', ['outer', 'inner'])

class Conf(object):
	def __init__(self, name, network, nat_interface, forwards):
		self.name = name
		self.network = IPv4Network(network.decode('utf-8'))
		self.nat_interface = nat_interface
		self.forwards = [
			forward.split(':') if ':' in forward else ('tcp', forward)
			for forward in forwards.split(',')
		] if forwards else []

	@property
	def netns(self):
		return self.name

	@property
	def bridge(self):
		return self.name

	@property
	def veths(self):
		return pair(*list('{}{}'.format(self.name, i) for i in range(2)))

	@property
	def addrs(self):
		return pair(*list(itertools.islice(self.network.hosts(), 2)))

	@property
	def addrs_with_prefix(self):
		def _addprefix(addr):
			return '{}/{}'.format(addr, self.network.prefixlen)
		return pair(*map(_addprefix, self.addrs))


def cmd(*args, **kwargs):
	print 'running', ' '.join(map(str, args))
	return easycmd.cmd(args, **kwargs)

sudo = functools.partial(cmd, 'sudo')
iptables = functools.partial(sudo, 'iptables')
brctl = functools.partial(sudo, 'brctl')
ip = functools.partial(sudo, 'ip')
ns_exec = functools.partial(ip, 'netns', 'exec')



def iptables_rules(conf):
	forward_rules = [
		('nat', [
			'PREROUTING',
			'-i', conf.bridge,
			'-d', conf.addrs.outer,
			'-p', proto,
			'--dport', port,
			'-j', 'DNAT',
			'--to-destination', '127.0.0.1',
		])
		for proto, port in conf.forwards
	]
	return [
		# NAT packets from inside ns to external network
		('nat', [
			'POSTROUTING',
			'-s', conf.addrs.inner,
			'-j', 'MASQUERADE',
		]),
		# Localhost forwards
	] + forward_rules + [
		# Allow packets to/from ns
		('filter', ['FORWARD', '-i', conf.bridge, '-j', 'ACCEPT']),
		('filter', ['FORWARD', '-o', conf.bridge, '-j', 'ACCEPT']),
	]


def cleanup(conf):
	no_error = {'success': 'nosignal'}
	# Remove iptables rules
	for table, rule in iptables_rules(conf)[::-1]:
		iptables('-t', table, '-D', *rule, **no_error)
	# Bring down and destroy the bridge
	ip('link', 'set', conf.bridge, 'down', **no_error)
	brctl('delbr', conf.bridge, **no_error)
	# Destroy the netns. This should also destroy the inner veth, which then destroys the outer veth.
	# But I've seen that not happen? so do that manually for good measure.
	ip('link', 'del', conf.veths.outer, **no_error)
	ip('netns', 'delete', conf.netns, **no_error)


def setup(conf):
	# Create the netns.
	# NOTE that we do not bring up the loopback interface inside the netns.
	# This matters because if the loopback interface gets address 127.0.0.1, then any outgoing
	# packets to 127.0.0.1 will have source 127.0.0.1 as well, which means they can't be
	# routed back. By not giving any of the interfaces inside the netns the 127.0.0.0/8 range,
	# it treats this range just like any other and uses its bridge ip as source ip.
	# However, this means that we could talk to 127.0.0.1 on any port and it would work,
	# so we need to add a reject rule to iptables filter.OUTPUT inside the netns.
	# This applies after any forwards in the nat.OUTPUT chain, so fowards still work.
	ip('netns', 'add', conf.netns)
	ns_exec(conf.netns, 'iptables', '-A', 'OUTPUT', '-d', '127.0.0.1/8', '-j', 'REJECT')
	# Create the veths, and put the inner one inside the netns
	ip('link', 'add', conf.veths.outer, 'type', 'veth', 'peer', 'name', conf.veths.inner)
	ip('link', 'set', conf.veths.inner, 'netns', conf.netns)
	# Create bridge and put outer veth onto it
	brctl('addbr', conf.bridge)
	brctl('addif', conf.bridge, conf.veths.outer)
	# Set addresses for bridge and inner veth, and set them up
	ip('addr', 'add', conf.addrs_with_prefix.outer, 'dev', conf.bridge)
	ns_exec(conf.netns, 'ip', 'addr', 'add', conf.addrs_with_prefix.inner, 'dev', conf.veths.inner)
	ip('link', 'set', conf.bridge, 'up')
	ip('link', 'set', conf.veths.outer, 'up')
	ns_exec(conf.netns, 'ip', 'link', 'set', conf.veths.inner, 'up')
	# We can now talk between the host ns (on the bridge interface) and the new ns.
	# Now we need to set up NAT and forwards.
	# We use -I to insert at the beginning because otherwise docker's default rules rather rudely
	# interfere and cause issues.
	for table, rule in iptables_rules(conf):
		iptables('-t', table, '-I', *rule)
	# In addition, we set up NAT inside the network namespace to transparently forward 'localhost'
	# packets to outside the namespace (where they are then forwarded to the main ns's localhost)
	for proto, port in conf.forwards:
		ns_exec(conf.netns, 'iptables', '-t', 'nat', '-I', 'OUTPUT',
			'-d', '127.0.0.1', 
			'-p', proto,
			'--dport', port,
			'-j', 'DNAT', '--to-destination', conf.addrs.outer,
		)
	# If we are doing any forwards, the route_localnet setting must be set on the bridge
	# to allow DNAT to localhost addresses.
	if conf.forwards:
		sudo('tee', '/proc/sys/net/ipv4/conf/{}/route_localnet'.format(conf.bridge), stdin="1")
		# and also on the other end for the return path
		ns_exec(conf.netns, 'tee', '/proc/sys/net/ipv4/conf/{}/route_localnet'.format(conf.veths.inner), stdin="1")
	# Finally, set the default route
	ns_exec(conf.netns, 'ip', 'route', 'add', 'default', 'via', conf.addrs.outer)


@argh.arg('--network', default='172.18.0.0/30')
@argh.arg('--nat-interface', default='eno1')
@argh.arg('--forwards', default='')
def main(name, command, *args, **kwargs):
	"""Run COMMAND inside a network namespace called NAME,
	with NATted access to the external network via NAT_INTERFACE.
	NETWORK is the address range used to give the new network namespace an address.
	It must have space for at least two addresses.
	The namespace is automatically cleaned up on process exit, but if you need to manually
	do a cleanup you can run it with the command 'clean'.
	You can selectively grant access to services running on localhost to the network namespace
	using the FORWARDS option, which should be a comma-seperated list of either tcp ports, or PROTO:PORT pairs.
	eg. to forward DNS (UDP and TCP) as well as tcp port 8080, you would do:
		--forwards=53,udp:53,8080
	"""
	conf = Conf(name, **kwargs)
	cleanup(conf)
	if command == 'clean':
		return
	setup(conf)
	ns_exec(conf.netns, command, *args, success='any', stdin=sys.stdin, stdout=sys.stdout, stderr=sys.stderr)
	cleanup(conf)


if __name__ == '__main__':
	argh.dispatch_command(main)
