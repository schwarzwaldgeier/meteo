#!/bin/bash
SECONDS_BEFORE_ALARM1=120
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
    for user in maxi.padulo@gmail.com dl4fly@darc.de; do
        echo -n "  $user..."
        echo -e "$MSG" | mail -s "WetterStation: $TITLE at $(date +%X)" $user
        echo "[DONE]"
    done
}

function back_to_normal {
    echo "BACK TO NORMAL: we are back"
    notify "everything OK" "Hello,\n\nthe Weather Station seems to be working again.\nHave a nice day ;)\n\nGreetz,\nWetterRobot" 
}

function no_data {
    notify "CheckError"
    echo "ALARM3 trigered"
    if [ ! -f $ALARM3_FLAG ]; then  # send only one notification
        touch $ALARM3_FLAG 
        notify "TimestampCheckError" "Could not get the last DB timestamp. Please see the check_station.sh script"
    fi
}

function trigger_alarm1 {
    echo "ALARM1 trigered"
    if [ ! -f $ALARM1_FLAG ]; then  # send only one notification
        touch $ALARM1_FLAG 
        notify "Alert1" "Hello,\n\nthe Weather Station reached ALERT_LEVEL=1.\nInitiating autorecovery procedure (kicking the router), wish me luck :)\n\nI should report myself later again. Keep an eye on it.\n\nGreetz,\nWetterRobot" 
    fi
    $ALARM1_CMD
}

function trigger_alarm2 {
    echo "ALARM2 trigered"
    if [ ! -f $ALARM2_FLAG ]; then 
        touch $ALARM2_FLAG 
        notify "Alarm2" "No data after $SECONDS_BEFORE_ALARM2. Do something!"
        notify "Alert2" "Hello,\n\nI'm sorry. After $SECONDS_BEFORE_ALARM2 there still no data.\nPlease do something, like checking the following logs:\n* /var/log/wetterstation/check_station.log\n* /var/log/wetterstation/wetterstation_daemon.log\n\nGreetz,\nWetterRobot" 
    fi
    $ALARM2_CMD
}

echo "Getting last entry from database..."
# weird URL I know...
DB_LAST=$(curl -s http://localhost:81/wetterstation/phone_neu.php)
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

# TODO: notify everything back to normal?
[ -f $ALARM1_FLAG ] && back_to_normal && rm -v $ALARM1_FLAG
[ -f $ALARM2_FLAG ] && back_to_normal && rm -v $ALARM2_FLAG
[ -f $ALARM3_FLAG ] && back_to_normal && rm -v $ALARM3_FLAG
