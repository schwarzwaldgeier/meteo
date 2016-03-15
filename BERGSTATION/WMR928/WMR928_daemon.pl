#!/usr/bin/perl -w
BEGIN {push @INC, "/var/www/BERGSTATION/WMR928/"}
my $basepfad = "/var/www/BERGSTATION/WMR928/";
my $logpfad = "/var/www/BERGSTATION/LOGS/wetterstation/";

use Carp;
use strict;
use LWP::Simple;
use Device::SerialPort 0.05;
my $port = "/dev/ttyS1";
#use Win32::SerialPort;
#my $port = "COM1";

my $PortObj;
$PortObj = Device::SerialPort->new ($port) or die "Can't start $port\n";
#$PortObj = Win32::SerialPort->new ($port) or die "Can't start $port\n";

$PortObj->baudrate(9600);
$PortObj->parity("odd");
$PortObj->databits(8);
$PortObj->stopbits(1);
$PortObj->parity_enable(0);
$PortObj->handshake("dtr");

my $print = 0;
if (defined @ARGV && $ARGV[0] eq '-p') {$print = 1;}

my $gotit = "";
my $count_in;
my $debug=0;
my $debuga=0;
my $keepit="";
my $sleep = 4;
my $avgsum = 1; my $avgcnt = 1;
my $logfile = $logpfad . 'log.txt';
my $archive = $logpfad . 'arch.txt';
my $lite = 'A2';
my $cmd = 'J';

# ----------- von der alten Software ----------------------- #
my $initialstart = 1;            # lets the serial buffer run to NULL when program comes up (do not change)
my $timecontrol = time();        # time for exit and restart when nothing happens (do not change)
my $timereset =  600000;         # program will restart when $timereset seconds nothing happens on serial
my $start = 0;                   # value of sequence (do not change)
my $newset = 0;                  # switch when new data sentence starts (do not change)
my $outi = "";                   # output data from serial device stored in this one (do not change)
my @adat = ();                   # output data is pushed into this array (do not change)
my $content = "";                # feedback of web-db-interface (do not change)
my $interval = 4;                # interval after how many sentences data is written do DB
my $intervaltime;                # output var only (how many seconds did $interval use) (do not change)
my $wd_u = 0;			 # winddirection vector (do not change)
my $wd_v = 0;			 # winddirection vector (do not change)
my $wd_w = 0;			 # winddirection angle (do not change)
my $pi = 3.141592645;		 # PI :-)
my $wd = 0;                      # winddirection is being counted up here (do not change)
my $ws = 0;                      # windspeed is being counted up here (do not change)
my $ws_max = 0;			 # windspeed maximum (do not change)
my $pr = 0;                      # atmospheric pressure is being pressure counted up here (do not change)
my $te = 0;                      # temperature is being counted up here (do not change)
my $lwd = 0;                     # winddirection for logging purposes (do not change)
my $lws = 0;                     # windspeed for logging purposes (do not change)
my $lpr = 0;                     # atmospheric pressure for logging purposes (do not change)
my $lte = 0;                     # temperature for logging purposes (do not change)
my $wdtmp = 0;
my $wdtmp1 = 0;
# -----------------------------------------------------------#

#---------------- RS232-Leseschleife START ------------------
while (1) {
	($count_in, $gotit) = $PortObj->read(100);
	#if ($gotit eq "") {
	#	print "Out ouf sync...\n";
	#	sleep 60;
	#	exit;
	#}
	sleep $sleep;
	print "sleep " . $sleep . "\n";
	next if $count_in == 0;
	$gotit = $keepit . $gotit if defined $keepit;

	my $bla = &read_wmr918($gotit,1);

	print "huhuuuuuuuuuuuuuu\n";

	
#    my @data = unpack('C*', $gotit);
#	print "\n---\n";
#	foreach (@data) { 
#		print $_ . ",";
#	}
#	print "\n---\n";
	

	print "\n---\n";
	print $gotit;
	print "\n---\n";
	#$weather{'Group'} = undef;
	#$keepit = &read_wmr918( $gotit, \%weather, $debug);
	#&process if defined $weather{'Group'};
}
#---------------- RS232-Leseschleife ENDE _------------------


sub read_wmr928 {
    my ($data, $debug) = @_;
    my @data = unpack('C*', $data);
	printf("Input : "."%x "x$#data."\n",@data) if $debug;
	#exit;
    my $iii = 0;
	while (@data) {
		print "dfsafasdfsd\n\n";
		# Ausschau halten nach den FF FF Inits und die Einträge trimmen (inkl. FF...)
		# Für den Fall, dass wir das Sync verlieren, wird ein Eintrag verworfen
		# und resynchronisiert
		my ($trim, $cnt) = (0,0);
		foreach (@data) {
			last if $cnt >= 2;
			$trim++;
			print "aaa" . $cnt . "aaa:" . $_ . "x" . $trim . "y ";
			#if ($_ == 0xff) {
			#	$cnt++
			#}
			#else {$cnt = 0;} # wir wollen nur aufeinanderfolgende FFs
			$cnt++;
		}
		if ($trim == @data) {$trim=0;}
		if ($trim > 2 && $debug) {
			print STDERR "===> trim = $trim\n";
			print STDERR "===> ",join(' : ',@data),"\n";
		}
		splice(@data,0,$trim) ; # Weg mit den FF FF Feldern
        my $group = $data[0];
        my $length = @data;
		#print "Gruppe: " . $group . ", ";
		#print "Datensatzlaenge: " . $length . ", ";
		print $iii;
		$iii++;
		### TODO zurück wenn laenge nicht stimmt
        # Wenn wir nicht genügende Daten bekommen haben: Wieder packen und zurück mit in die
        # Schleife für den nächsten Durchlauf...
        #if ($$dtp[1] > @data) {
        #    return pack('C*', @data);
        #}
    }
	return;
}


sub read_wmr918 {
    my ($data, $debug) = @_;

    my @data = unpack('C*', $data);
	printf("Input : "."%x "x$#data."\n",@data) if $debug;

    while (@data) {
		# Ausschau halten nach den FF FF Inits und die Einträge trimmen (inkl. FF...)
		# Für den Fall, dass wir das Sync verlieren, wird ein Eintrag verworfen
		# und resynchronisiert
		my ($trim, $cnt) = (0,0);
		foreach (@data) {
			last if $cnt >= 2;
			$trim++;
			if ($_ == 0xff) {
				print "GOT FF !!!!!!!!!!!!!!!!!!!!!!!!!!!!\n";
				$cnt++;
			}
			else {$cnt = 0; print "hhhhhhhhhhhhhhhhhhh " . $_ . " iiiiiiiiiiiiiiiii\n"; sleep 1;} # wir wollen nur aufeinanderfolgende FFs
		}
		if ($trim == @data) {$trim=0;}
		if ($trim > 2 && $debug) {
			print STDERR "===> trim = $trim\n";
			print STDERR "===> ",join(' : ',@data),"\n";
		}
		splice(@data,0,$trim) ; # Weg mit den FF FF Feldern
        my $group = $data[0];
        my $length = @data;
		print "Gruppe: " . $group . ", ";
		print "Datensatzlaenge: " . $length . "\n";
		
        # Die Anzahl der Bytes rausziehen, die wir für diesen Typ brauchen
		my $slength = 4;
		if ($group == 0x00) { $slength = 9; }
		if ($group == 0xff) { $slength = 14; }
		
        my @data2 = splice(@data, 0, $slength);
		
		
    }
	return;
}


sub logme {
	print $_[1] . "\n";
}

