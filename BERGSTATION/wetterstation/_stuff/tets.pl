#!/usr/bin/perl
#
#
# Author: Bruce S. Garlock
# Date:   2002-09-11
# Requirements: Device::SerialPort 0.12 (from cpan)
#
# Version: 0.1
#
#
# Description:  This perl script is for logging of data from a serial
# port, to a specified logfile.  The logfile can then be parsed with
# other programs for reporting purposes.
# 
# This program was written for specifically logging Multitech's
# MTASR2-203 T1 Router.  The router outputs text to the command
# port with 57.6k, 8-1-N, and No flow control.
#
#

use Device::SerialPort 0.12;

$LOGDIR    = "/var/www/TRANS/wetterstation/";              # path to data file
$LOGFILE   = "router.log";            # file name to output to
$PORT      = "/dev/ttyS1";          # port to watch

#
#
# Serial Settings
#
#

$ob = Device::SerialPort->new ($PORT) || die "Can't Open $PORT: $!";
$ob->baudrate(9600)   || die "failed setting baudrate";
$ob->parity("none")    || die "failed setting parity";
$ob->databits(8)       || die "failed setting databits";
$ob->handshake("none") || die "failed setting handshake";
$ob->write_settings    || die "no settings";

#
# Send a string to the port
#
#

$pass=$ob->write("AT");
sleep 1;

#
# open the logfile, and Port
#

open(LOG,">>${LOGDIR}/${LOGFILE}")
    ||die "can't open smdr file $LOGDIR/$LOGFILE for append: $SUB $!\n";

open(DEV, "<$PORT") 
    || die "Cannot open $PORT: $_";

select(LOG), $| = 1;      # set nonbufferd mode

#
# Loop forver, logging data to the log file
#

while($_ = <DEV>){        # print input device to file
	echo $_;
    print LOG $_;
}

undef $ob;
