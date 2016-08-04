#!/bin/bash
# Load email addresses from sensitive
set -e; source /var/www/.sensitive; set +e 
#EMAIL_LIST
DATA_URL=http://localhost:81/wetterstation/phone_neu.php
SECONDS_BEFORE_ALARM1=300
SECONDS_BEFORE_ALARM2=900     # should be bigger than alarm1
ALARM1_FLAG=/tmp/alarm1.flag  # Flags used to run alarms only once
ALARM1_CMD=/var/www/BERGSTATION/monitor/wlan_router_in_den_arsch_tretten.sh
ALARM2_FLAG=/tmp/alarm2.flag
ALARM1_CMD=/var/www/BERGSTATION/monitor/wlan_router_in_den_arsch_tretten.sh
ALARM3_FLAG=/tmp/alarm3.flag  

TF_DIR=/tmp/  # Test files for tstamp comparission (bash style sorry)

function notify {
    TITLE=$1
    MSG=$2
    echo "Sendig alert: [$TITLE]: $MSG" 
    # Not so reliable, deprecating it. Will use standar mail
    # PRIORITY=2  # 2: High, 0: Normal
    # /var/www/BERGSTATION/monitor/android_notify.sh WetterStation "$TITLE" "$MSG" $PRIORITY

    # send mail
    echo "Sending mail..."
    # Mail return allways 0. Pipeing stderr to detect for errors
    set -x
    ret=$(echo -e "$MSG" | mail -s "WetterStation: $TITLE at $(date +%X)" $EMAIL_LIST 3>&2 2>&1 1>&3 | tee -a /dev/fd/2 |  wc -l)
    set +x
    echo "[Returned]: $ret"
   
    return $ret
}

function back_to_normal {
    echo "BACK TO NORMAL: we are back"
    notify "everything OK" "Hello,\n\nthe Weather Station seems to be working again.\nHave a nice day ;)\n\nGreetz,\nWetterRobot" 
    return $?
}

function no_data {
    echo "ALARM3 trigered"
    if [ ! -f $ALARM3_FLAG ]; then  # send only one notification
        notify "TimestampCheckError" "Could not get the last DB timestamp from $DATA_URL.\nPlease see the check_station.sh script and the logs in /var/log/wetterstation"
        [ $? -eq 0 ] && touch $ALARM3_FLAG 
    fi
}

function trigger_alarm1 {
    echo "ALARM1 trigered"
    if [ ! -f $ALARM1_FLAG ]; then  # send only one notification
        notify "Alert1" "Hello,\n\nthe Weather Station reached ALERT_LEVEL=1.\nI will start the recovery script, hope that helps.\n\nI should report myself later again. Keep an eye on it.\n\nGreetz,\nWetterRobot" 
        [ $? -eq 0 ] && touch $ALARM1_FLAG 
    fi
    $ALARM1_CMD
}

function trigger_alarm2 {
    echo "ALARM2 trigered"
    if [ ! -f $ALARM2_FLAG ]; then 
        touch $ALARM2_FLAG 
        notify "Alert2" "Hello,\n\nI'm sorry. After $SECONDS_BEFORE_ALARM2 seconds there still no data. Radio will be turned off, telefone will say report the problem.\nPlease do something, like checking the following logs:\n* /var/log/wetterstation/check_station.log\n* /var/log/wetterstation/wetterstation_daemon.log\n\nGreetz,\nWetterRobot" 
        [ $? -eq 0 ] && touch $ALARM2_FLAG 
    fi
    $ALARM2_CMD
}

echo "Getting last entry from database..."
# weird URL I know...
DB_LAST=$(curl -s $DATA_URL)
[ "$?" -ne 0 ] && { echo "Unable to get data..."; no_data ; exit 10; }


# Parse the timestamp (third value)
#    '12,354,1458308820x6,31x7,15x15,354' # Test sample
TSTAMP=$(echo $DB_LAST | cut -d',' -f3 | cut -d'x' -f1)

ALARM1_TSTAMP=$((TSTAMP + SECONDS_BEFORE_ALARM1))
ALARM2_TSTAMP=$((TSTAMP + SECONDS_BEFORE_ALARM2))


[ -z "$ALARM1_TSTAMP" ] && { echo "Unexpected data..."; no_data ; exit 11; }

FLT="$TF_DIR/last_timestamp.placeholder"
FCT="$TF_DIR/current_timestamp.placeholder"
FA1="$TF_DIR/alarm1_timestamp.placeholder"
FA2="$TF_DIR/alarm2_timestamp.placeholder"

touch -d "@$TSTAMP" $FLT
touch $FCT
touch -d "@$ALARM1_TSTAMP" $FA1
touch -d "@$ALARM2_TSTAMP" $FA2

echo "Last entry from:  $(stat -c %y $FLT)"
echo "Current:          $(stat -c %y $FCT)"
echo "Timestamp ALARM1: $(stat -c %y $FA1)"
echo "Timestamp ALARM2: $(stat -c %y $FA2)"

# NOTE: Keep reverse order
[ $FCT -nt $FA2 ] && { trigger_alarm2; exit 2; }
[ $FCT -nt $FA1 ] && { trigger_alarm1; exit 1; }

set -x
[ -f $ALARM1_FLAG ] || [ -f $ALARM2_FLAG ] || [ -f $ALARM3_FLAG ] && back_to_normal && rm -vf $ALARM3_FLAG && rm -fv $ALARM2_FLAG && rm -fv $ALARM1_FLAG
