import math
import subprocess
from collections import namedtuple

import argh


@argh.arg('videos', nargs='+')
def main(output_file, videos, cols=4, size='1920x1080'):
	full_size = [int(part) for part in size.split('x')]
	rows = int(math.ceil(len(videos) / float(cols)))
	assert rows * cols >= len(videos)
	video_size = [part / count for part, count in zip(full_size, (cols, rows))]
	print "Putting {} videos into a {}x{} grid at {}x{} each".format(len(videos), cols, rows, *video_size)

	args = ['ffmpeg', '-hide_banner']
	for video in videos:
		args += ['-i', video]

	filters = [
		'nullsrc=size={}x{} [base]'.format(*full_size),
	]
	for i in range(len(videos)):
		filters.append('[{i}:v] scale={size[0]}x{size[1]} [scaled{i}]'.format(i=i, size=video_size))
	for i in range(len(videos)):
		inp1 = '[base]' if i == 0 else '[overlay{}]'.format(i - 1)
		inp2 = '[scaled{}]'.format(i)
		out = '' if i == len(videos) - 1 else '[overlay{}]'.format(i)
		row, col = divmod(i, cols)
		filters.append('{}{} overlay=x={}:y={} {}'.format(
			inp1, inp2,
			video_size[0] * col,
			video_size[1] * row,
			out,
		))

	args += [
		'-filter_complex', ';\n'.join(filters),
		'-c:v', 'libx264',
		'-preset', 'ultrafast',
		'-crf', '0',
		'-y', output_file,
	]

	print "Calling ffmpeg with args:"
	print ' '.join(args)

	subprocess.check_call(args)


if __name__ == '__main__':
	argh.dispatch_command(main)
