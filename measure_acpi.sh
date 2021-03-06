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

mkdir -pv ${1:-log} >&2

for ce in 0 1; do
for rth in 0 1; do
for  eeo in 0 1; do
	(
	echo 'Benchmark,Time,Time_stdev,Freq,Actual_Freq,Cycles,Branches,Insns,E_pkg,E_cores,E_ram,Cycles_stdev,Branches_stdev,Insns_stdev,E_pkg_stdev,E_cores_stdev,E_ram_stdev'

	for freq in $(< /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies); do
	echo "Freq: $freq" >&2
	ensure MSR_POWER_CTL:1=$ce >&2
	ensure MSR_POWER_CTL:19=$rth >&2
	ensure MSR_POWER_CTL:20=$eeo >&2
	if [ $freq == 3401000 ]; then
		ensure IA32_MISC_ENABLE:38=0 >&2
	else
		ensure IA32_MISC_ENABLE:38=1 >&2
	fi
#	ensure IA32_HWP_REQUEST:24-31=$epp >&2
	for cpuf in /sys/devices/system/cpu/cpu[0-9]*; do
		echo $freq >$cpuf/cpufreq/scaling_setspeed
	done
	for bench in "sleep 2" ./arith ./fast_arith ./mem ./fast_mem ./rep_mem "../firestarter/FIRESTARTER/FIRESTARTER -t5"; do
	echo "[$(date +%H:%M:%S:%N)] Bench: $bench" >&2
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
	echo "$bench,$TIME,${TIME_STDDEV},$freq,$AFREQ,$CYCLES,$BRANCHES,$INSTRUCTIONS,$EPKG,$ECORES,$ERAM,${CYCLES_STDDEV},${BRANCHES_STDDEV},${INSTRUCTIONS_STDDEV},${EPKG_STDDEV},${ECORES_STDDEV},${ERAM_STDDEV}"
	done
	done
	) >${1:-log}/result_c1e=${ce}_rth=${rth}_eeo=${eeo}.csv
done
done
done
