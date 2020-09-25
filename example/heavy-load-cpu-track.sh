#!/usr/bin/env sh

kill $(ps -ef | grep proc-monitor.sh | awk '{print $2}')

nohup ${PWD}/../proc-monitor.sh -t H -n 0.9 \
	-o "user,pid,ppid,lwp,nlwp,stime,time,%cpu,priority,%mem,vsize,cls,cmd" \
	-s "%cpu" -f '$(f["%CPU"]) > 5' -l ~/cpu-load-process-log-$(date +%s).csv > /dev/null &
