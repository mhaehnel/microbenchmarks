#!/usr/bin/env bash
for i in {0..7}; do
	taskset -c $i "$@" &
done
wait
