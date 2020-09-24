Process Monitoring Script
===============================================
This script is used to monitor the process status with some fliters.

Usage
-----------------------------------------------
```
proc-monitor.sh [options]
options:
  -t <thread-switch>,   the threading switch, only allowed for "H", "m", or "L".
  -n <interval-sec>,    the interval seconds for `watch` command
  -o <print-opts>,      the orded opts for `ps` command, it will pass to `-o` args
  -f <filter>,          the filter used for `awk '("col-1" >= 1  && "col-2" < 2){print;}'`
  -l <log-file>,        the logger file
```

