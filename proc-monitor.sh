#!/usr/bin/env bash

#example process
ps -m -eo user,pid,ppid,lwp,nlwp,time,%cpu,priority,rtprio,%mem,vsize,cls,psr,cmd --sort=+pcpu | \
        awk -v timestamp="$(date +%s)" '($7 >= 5) {print timestamp, $0;}'
