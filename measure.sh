#!/usr/bin/env bash

. ../models/tools/msr_tool.sh

extractStdDev() {
        grep $1 tmp.csv  | sed -e 's/^.*( +-[ ]*\([0-9.]*\)% ).*$/\1/;s/,//g'
}

extractValue() {
        grep $1 tmp.csv  | sed -e 's/^[ ]*\([0-9,.]*\) .*$/\1/;s/,//g'
}

extractBoth() {
	local NAME=${2:-${1^^}};
	local SSTR=${1};
	declare -g ${NAME}=$(extractValue $SSTR)
	declare -g ${NAME}_STDDEV=$(extractStdDev $SSTR);
}

#Min
ensure IA32_HWP_REQUEST:0-7=1
#Max
ensure IA32_HWP_REQUEST:8-15=40
#Auto desired
ensure IA32_HWP_REQUEST:16-23=0
#EPP

mkdir -pv ${1:-log} >&2

for ce in 0 1; do
for rth in 0 1; do
for  eeo in 0 1; do
	(
	echo 'Benchmark,Time,Time_stdev,Epp,Actual_Freq,Cycles,Branches,Insns,E_pkg,E_cores,E_ram,Cycles_stdev,Branches_stdev,Insns_stdev,E_pkg_stdev,E_cores_stdev,E_ram_stdev'

	for epp in `seq 0 8 255` 255; do
	ensure MSR_POWER_CTL:1=$ce >&2
	ensure MSR_POWER_CTL:19=$rth >&2
	ensure MSR_POWER_CTL:20=$eeo >&2
	ensure IA32_HWP_REQUEST:24-31=$epp >&2
	for bench in "sleep 2" ./arith ./fast_arith ./mem ./fast_mem ./rep_mem "../firestarter/FIRESTARTER/FIRESTARTER -t5"; do
	echo "Bench: $bench" >&2
	if [[ $bench =~ ^\.\./ ]]; then
		perf stat -r 10 -a -e cycles,instructions,branches,power/energy-pkg/,power/energy-cores/,power/energy-ram/ -o tmp.csv $bench &>/dev/null &
	else
		perf stat -r 10 -a -e cycles,instructions,branches,power/energy-pkg/,power/energy-cores/,power/energy-ram/ -o tmp.csv ./cora.sh $bench &>/dev/null &
	fi
	sleep 1
	AFREQ=$(< /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq)
	wait
	extractBoth time
	extractBoth cycles
	extractBoth instructions
	extractBoth branches
	extractBoth energy-pkg EPKG
	extractBoth energy-ram ERAM
	extractBoth energy-cores ECORES
	echo "$bench,$TIME,${TIME_STDDEV},$epp,$AFREQ,$CYCLES,$BRANCHES,$INSTRUCTIONS,$EPKG,$ECORES,$ERAM,${CYCLES_STDDEV},${BRANCHES_STDDEV},${INSTRUCTIONS_STDDEV},${EPKG_STDDEV},${ECORES_STDDEV},${ERAM_STDDEV}"
	done
	done
	) >${1:-log}/result_c1e=${ce}_rth=${rth}_eeo=${eeo}.csv
done
done
done
