Process Monitoring Script
===============================================
This script is used to monitor the process status with some fliters.

Usage
-----------------------------------------------
```
proc-monitor.sh [options]
options:
  -t "<thread-switch>", the threading switch, only allowed for "H", "m", or "L", default: "H"
  -n "<interval_sec>",  the interval_sec for bash `sleep` command, 0 means disable,
                        default: "0"
  -o "<ps-opts>",       the orded opts for `ps` command, it will pass to `-o` args,
                        default: "user,pid,ppid,stime,time,%cpu,%mem,cmd"
  -s "<sort-column>",   the sort options for `ps` command, it will pass to `-sort` args,
                        default: ""
  -f "<filter>",        the filter used for awk "("col-1" >= 1  && "col-2" < 2){print;}",
                        default: "1".
  -l "<log-file>",      the logger file, default ""
tips for `awk` filter, allow to use $(f["PID"]) to select the PID column.
```

