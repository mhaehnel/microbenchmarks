#!/usr/bin/env bash
declare -i MASK=$(( 16#$(taskset -p $$ | cut -f2 -d\: | tr -d ' ') )) POS=0
while [ $MASK -ne 0 ]; do
	echo "$POS: $(($MASK%2)) $MASK $(($MASK>>1))"
	if [ $(( $MASK%2 )) -eq  1 ]; then
		taskset -c ${POS} "$@" &
	fi
	let POS+=1
	MASK=$(($MASK>>1))
done
wait
