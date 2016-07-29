#!/bin/bash
#########################################################################################
### androidNotifty.sh                                                                   #
### Script for sending notifications using "Notify My Androids" API                     #
###    Author : Markp1989@gmail.com  Version: 25JULY2011                                #
#########################################################################################
## Requirements:    curl                                                                #
#########################################################################################
## Usage: androidNotify.sh "Application Name" "Event Name" "Some Details" [priority]    #
#########################################################################################
## API Documentation:   https://www.notifymyandroid.com/api.jsp      #
#########################################################################################

# Get password and IP from a file outside repository control
set -e; source /var/www/.sensitive; set +e
APIkey=$ANDROIDNOTIFY_APIKEY ## API Key must me set here, go to http://www.notifymyandroid.com/ to get one
limit=5 # how many times to attempt to run curl, can help on unstable networks.
pinghost="google.com" ##host to ping before running anything to verify that the internet is up.
#####end user configurable settings######

##renaming parameters to make rest of the code more readable.
command=$0
application=$1
event=$2
description=$3
priority=$4 

##the urls that are used to send the notification##
baseurl="https://www.notifymyandroid.com/publicapi"
verifyurl="$baseurl/verify"
posturl="$baseurl/notify"

##choosing a unique temp file based on the time (date,month,hour,minute,nano second),to avoid concurent usage interfering with each other
notifyout=/tmp/androidNotify$(date '+%d%m%Y%H%M%S%N')

usage="Usage: $command Application Event Description [priority]"
##exit functions so i dont have to keep writing the same exit messages for every fail. 
function error_exit {
##this function is used to exit the program in the event of an error.
       printf '%s\n\t%s\n\t\t%s\n' "[ Error ] Notification not sent:" "$errormessage" "$usage"
printf '\n%s\n' "$application , $event , $description, priority=$priority" >> $notifyout ##adding info used to tmp file. 
       exit 1

}
function clean_exit {
       printf '%s\n' "[ info ] Notification sent"
rm "$notifyout" ##removing output file when notification was sent okay
       exit 0
}


function pre_check {
##this function checks that curl is installed, and that an internet connection is available 
which curl >/dev/null  || { errormessage="curl is required but it's not installed, exiting."; error_exit; }
##checking that the machine can connect to the internet by pinging the host defined in $pinghost
ping -c 5 -w 10  "$pinghost" >/dev/null || { errormessage="internet connection is required but not connected, exiting."; error_exit; }
}

function input_check { 
##this section checks that the parameters are an acceptable length if any of these tests fail then the program exits.
##the API will send an error back if the data sent is invalid, but no point in knowingly sending incorrect information.
#API key must be 48 characters long, just because the APIkey is the right length doesnt mean its valid,the API will complain if it is invalid.
if [[ "${#APIkey}" -ne "48" ]]; then
errormessage="APIkey must be 48 characters long, you gave me ${#APIkey}"
       error_exit
#application must be between 1 and 256 characters long
elif [[ "${#application}" -gt "256" ||  "${#application}" -lt "1" ]]; then
       errormessage="[ error ] the application parameter is invalid or missing"
error_exit
#event must be between 1 and 1000 characters long
elif [[ "${#event}" -gt "1000"  ||  "${#event}" -lt "1" ]]; then
       errormessage="[ error ] the event parameter is invalid or missing"
error_exit
#description must be between 1 and 1000 characters long
elif [[ "${#description}" -gt "1000"  ||  "${#description}" -lt "1" ]]; then
errormessage="[ error ] the description parameter is invalid or missing"
error_exit
##priority is expected to be between -2 and 2, if other numbers are given than default(0) is used.
fi

if [ -z $priority ]; then
printf '%s\n' "priority is not set , must be between -2 and 2, using 0 instead"
       priority=0
elif [[ "$priority" -gt "2" || $priority -lt "-2" ]]; then
printf '%s\n' "priority $priority is invalid, must be between -2 and 2, using 0 instead"
priority=0
fi

if [[ -n "$5" ]]; then
errormessage="[ error ] too many parameters have been provided:"
error_exit
fi

}

function send_notification {
##sending the notification using curl
#if curl failes to complete then it will try again, untill the "limit" is met,or curl runs ok.
complete=0
tries=0
while [[ $complete -lt 1 && $tries -lt $limit ]]
do
#if curl is already running that we wait up to a minute before proceding
if [ "$(pidof curl)" ]
then
 printf '%s\n' "another instance of curl is running, waiting up to 1 minute before trying."
 sleep $((RANDOM % 60)) ##waiting up to 1 minute as running multiple instances of curl at a time was causing some to fail on my machine.
fi
curl --silent --data-ascii "apikey=$APIkey" --data-ascii "application=$application" --data-ascii "event=$event" --data-asci "description=$description" --data-asci "priority=$priority" $posturl -o $notifyout && complete=1
tries=$tries+1
done
}

function check_notification {
##checking that the notification was sent ok.
##api returns message 200 if the notification was sent
if grep -q 200 $notifyout; then
clean_exit
else
##getting the error reported by the API, this may break if the API changes its output, will change as soon as I can find a commandline xml parser
errormessage="$(cut -f4 -d'>' $notifyout | cut -f1 -d'<')"

error_exit
fi
}

##running the functions
pre_check
input_check
send_notification
check_notification

