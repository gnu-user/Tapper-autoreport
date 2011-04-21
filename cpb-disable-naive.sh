#! /bin/bash

#NOSEND=1

#SIZE_MB=10
SIZE_MB=4096
DATAFILE="/tmp/cpb_random_data_$$.dat"
TIMEFILE="/tmp/cpb_time_$$.dat"
SYS_CPB="/sys/devices/system/cpu/cpu0/cpufreq/cpb"
FORMAT="%U"

. ./tapper-autoreport --import-utils

# ==================== UTILS ====================

enable_cpb() {
        OLDCPB=$(cat $SYS_CPB)
        echo 1 > $SYS_CPB
	#echo '# enable cpb to' $(cat $SYS_CPB) 1>&2
}

disable_cpb() {
        OLDCPB=$(cat $SYS_CPB)
        echo 0 > $SYS_CPB
	#echo '# disable cpb to' $(cat $SYS_CPB) 1>&2
}

restore_cpb() {
    echo $OLDCPB > $SYS_CPB
    #echo '# restore cpb to' $(cat $SYS_CPB) 1>&2
}

# ==================== REQUIREMENTS ====================

require_cpufeature "cpb"
require_program "bc"
require_root

#echo '# generate data file...' 1>&2
dd if=/dev/zero of=$DATAFILE count=$((1024*1024)) ibs=$SIZE_MB > /dev/null 2>&1

# ==================== PREPARE ====================

# ==================== WARMUP RUN ====================

#echo '# warmup run...' 1>&2
/usr/bin/time -o $TIMEFILE --format "$FORMAT" md5sum $DATAFILE > /dev/null 2>&1
TIME_WARMUP=$(cat $TIMEFILE)
#echo '# warmup time:' $TIME_WARMUP 1>&2

# ==================== FIRST RUN ====================

enable_cpb

#echo '# measure time with cpb...' 1>&2
/usr/bin/time -o $TIMEFILE --format "$FORMAT" md5sum $DATAFILE > /dev/null 2>&1
TIME_CPB=$(cat $TIMEFILE)
#echo '# cpb time:' $TIME_CPB 1>&2

restore_cpb

# ==================== SECOND RUN ====================

disable_cpb
   
#echo '# measure time with cpb disabled...' 1>&2
/usr/bin/time -o $TIMEFILE --format "$FORMAT" md5sum $DATAFILE > /dev/null 2>&1
TIME_NOCPB=$(cat $TIMEFILE)
#echo '# no cpb time:' $TIME_NOCPB 1>&2

restore_cpb

# ==================== RATIO CPB vs. NOCPB ====================

NOT0A=$(bc -lq <(echo "$TIME_CPB   > 0; halt"))
NOT0B=$(bc -lq <(echo "$TIME_NOCPB > 0; halt"))
if [ $NOT0A -a $NOT0B ] ; then # avoid division by zero
    TIME_RATIO=$(bc -lq <(echo "$TIME_CPB / $TIME_NOCPB ; halt"))
else
    TIME_RATIO="~" # YAML undef
    SKIP="# SKIP ignored due to runtime of zero time"
fi

# ==================== FASTER? ====================

SUCCESS=0
if [ ! "$SKIP" ] ; then
    SIGNIFICANTLY_FASTER=$(bc -lq <(echo "$TIME_RATIO < 0.95; halt"))
    #echo '# significantly faster:' $SIGNIFICANTLY_FASTER 1>&2
    if [ "x1" != "x$SIGNIFICANTLY_FASTER" ] ; then
        SUCCESS=1
    fi
fi

# ==================== TAP ====================

ok $SUCCESS "CPB faster than no CPB $SKIP"

append_tapdata "timecpb: $TIME_CPB"
append_tapdata "timenocpb: $TIME_NOCPB"
append_tapdata "ratio: $TIME_RATIO"

# ==================== CLEANUP ====================

/bin/rm $DATAFILE
/bin/rm $TIMEFILE

# ==================== DONE ====================
        
# ==================== REPORT ====================

. ./tapper-autoreport
