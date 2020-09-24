#!/usr/bin/env bash

HelpText='
proc-monitor.sh [options] \n
options: \n
  -t "<thread-switch>", the threading switch, only allowed for "H", "m", or "L", default: "H" \n
  -n "<interval_sec>",  the interval_sec for bash `sleep` command, 0 means disable,
                        default: "0" \n
  -o "<ps-opts>",       the orded opts for `ps` command, it will pass to `-o` args,
                        default: "user,pid,ppid,stime,time,%cpu,%mem,cmd" \n
  -s "<sort-column>",   the sort options for `ps` command, it will pass to `-sort` args,
                        default: "" \n
  -f "<filter>",        the filter used for awk "("col-1" >= 1  && "col-2" < 2){print;}",
                        default: "1". \n
  -l "<log-file>",      the logger file, default "" \n
tips for `awk` filter, allow to use $(f["PID"]) to select the PID column.
'

POSITIONAL=()
local_thread_switch="H"
local_interval_sec=0
local_ps_opts="user,pid,ppid,stime,time,%cpu,%mem,cmd"
local_ps_sort=""
local_filter=1

while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
        -t)
            local_thread_switch="$2"
            shift
            shift
            ;;
        -n)
            local_interval_sec="$2"
            shift
            shift
            ;;
        -o)
            local_ps_opts="$2"
            shift
            shift
            ;;
        -s)
            local_ps_sort="$2"
            shift
            shift
            ;;
        -f)
            local_filter="$2"
            shift
            shift
            ;;
        -l)
            local_logfile="$2"
            shift
            shift
            ;;
        *)
            POSITIONAL+=("$1")
            shift
            ;;
    esac
done

if [[ ${POSITIONAL[$#]} > 0 ]]; then
    echo -e $HelpText
    exit 1
fi

if [[ $local_thread_switch != H && $local_thread_switch != m && $local_thread_switch != L ]]
    then
    echo "ERR: not support <$local_thread_switch>..."
    echo ""
    echo -e $HelpText
    exit 1
fi

if [[ $local_interval_sec -lt 0 ]]; then
    echo "ERR: the interval-sec should be bigger than 0..."
    echo ""
    echo -e $HelpText
    exit 1
fi

function awk_selecing()
{
    awk -v timestamp=$(date +"%s.%N") "
    (NR == 1) {
        for (i=1; i <= NF; i++) {
            f[\$i] = i
        }
    }
    ($local_filter) {
        print timestamp, \$0;
    }
    " -
}

function ps_function()
{
    if [[ -z $local_ps_sort ]]; then
        ps $local_thread_switch -eo "$local_ps_opts" | awk_selecing
        return $?
    else
        ps $local_thread_switch -eo "$local_ps_opts" --sort=$local_ps_sort | awk_selecing
        return $?
    fi
}

function conv_space_to_comma_csv()
{
    sed -e 's:\s\s*:,:g' - | sed -e 's:,$::g' - | sed -e 's:^,::g' -
}

function print_header()
{
    echo "timestamp,$local_ps_opts" | tr '[:lower:]' '[:upper:]'
}

if [[ $local_logfile ]]; then
    print_header > $local_logfile
fi

while : ; do
    #start_timing=$(date +%s.%N)
    print_header
    echo "----------------------------"
    if [[ $local_logfile ]]; then
        ps_function | conv_space_to_comma_csv | tail -n +2 | tee -i -a $local_logfile
        ret=$?; if [[ $ret -ne 0 ]]; then
            exit $ret
        fi
    else
        ps_function | conv_space_to_comma_csv | tail -n +2
        ret=$?; if [[ $ret -ne 0 ]]; then
            exit $ret
        fi
    fi
    if [[ $local_interval_sec != 0 ]]; then
        #now_timing=$(date +%s.%N)
        sleep $local_interval_sec
    else
        break;
    fi
done

#example process
#ps -m -eo user,pid,ppid,lwp,nlwp,time,%cpu,priority,rtprio,%mem,vsize,cls,psr,cmd --sort=+pcpu | \
        #awk -v timestamp="$(date +%s)" '($7 >= 5) {print timestamp, $0;}'
