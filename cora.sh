#!/usr/bin/env bash
for i in $(seq 0 $(($(nproc --all)-1))); do
	[ $(< /sys/devices/system/cpu/cpu$i/online) -eq 1 ] && echo $i && taskset -c $i "$@" &
done
wait
