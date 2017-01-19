#!/bin/bash 

if [ $# -lt 2 ]; then
    echo Not enough parameters.
    echo
    echo Allows to make a git commit at an arbitrary date/time
    echo Usage: $0 YYYY-mm-dd HH:MM:SS [OTHER GIT PARAMETERS]
    exit -1
fi

GIT_DATE=`date -d "$1 $2" "+%s %z"`

#echo Changing system date. Provide sudo password.
#sudo date -s"$1 $2"

if [ $? -ne 0 ]; then 
    echo
    echo ERORR: Problem with date convertion. Check date format.
    echo Usage: $0 YYYY-mm-dd HH:MM:SS [OTHER GIT PARAMETERS]
    exit -2
fi

echo Selected date to commit $1 $2

# Get rid of date parameters, and leave only the rest.
shift
shift

echo Parameters for commit: $*
echo
echo Press ENTER to continue, Ctr+C to abort...
read

# Load environment variables and call git commit with parameters
GIT_AUTHOR_DATE="$GIT_DATE" \
GIT_COMMITTER_DATE="$GIT_DATE" \
git commit $*

#echo Changing system date with ntpdate. Provide sudo password.
#sudo ntpdate -u ntp.ubuntu.com

