#!/bin/bash

xdotool search --name --limit 1 'Crypt of the NecroDancer' type --window '%1' --delay 75 "$(python -c 'import random; print random.randrange(1000000)')"
