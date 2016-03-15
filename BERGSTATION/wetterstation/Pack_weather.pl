#!/usr/bin/perl -w

BEGIN {push @INC, "/home/ajackson/bin/lib"}
use strict;

use Weather::ReadArch;
use Weather::Math;

#	Pack a daily archive into a more compact form

#	Rainfall totals when they change (previous 10 minutes)
#	Wind speed and dir 10 min avgs
#	10 minute T, H, B averages

#	file will look like this :
#	## date 1/5/2000
#	## input file arch12345678
#	## rainfall
#	04:10 0.03
#	04:20 0.06
#	04:30 0.09
#	## other data
#	## begin time 00:10
#	TO TI HO HI DO DI WC WG WA WD

### to do
#		document

die "archive name?\n" if @ARGV==0;
my $archive = $ARGV[0];
my $wdir = $ARGV[1];

my $test = 0;
$test = 1 if defined $ARGV[2];

my $RdAr = Weather::ReadArch->new("$wdir/$archive");

$RdAr -> read;

#---------------------------------------------------
#------------ do rainfall
#---------------------------------------------------

my $RT = $RdAr -> getsec('RT');
my $rain = Weather::Math->new;
my $error = $rain->load($RT);
if ($error) {die "Rain loading error, $error\n";}
$rain->nodata(-999);
$error = $rain->despike(5); # 5 inch rainfall spikes are skipped
if ($error) {die "Rain despiking error, $error\n";}
$error = $rain->monotonic;
if ($error) {die "Rain monotonic error, $error\n";}
$rain->start_stop('midnight');
$rain->nodata(-999);
$rain->window(10*60);
$error = $rain->sample;
if ($error) {die "Rain sampling error, $error\n";}
my @rmax = @{$rain->max};
my @timedef = @{$rain->timedef};
my $RainTotal = $rain->max->[-1] - $rain->max->[0];

$rain->derivative('max');
my @deriv = @{$rain->deltas};

#  what is the date?

my @y = localtime($timedef[0]+12*60*60);
my $date = sprintf("%d/%d/%4d",$y[4]+1, $y[3], $y[5]+1900 );
my $midnight = $timedef[0];

#	open output file

my $dashdate = $date;
$dashdate =~ s%/%-%g;
open (OUT,">$wdir/pack_".$dashdate)|| die "Can't open output, $!\n";

print OUT "## date $date\n";
print OUT "## input file $archive\n";
print OUT "## rainfall\n";

#	output rainfall

foreach (@deriv) {
	print OUT hour_min($_->[0]), sprintf(" %6.3f",$_->[1]),"\n";
}

#---------------------------------------------------
#------------ do all the rest
#---------------------------------------------------

print OUT "## extrema data\n";

my %arrays;

#	Various types of temperature data and pressure data

foreach (qw/TO TI HO HI DO DI BR/) {
	my $temp = Weather::Math->new;
	$temp->nodata(-999);
	$error = $temp->load($RdAr -> getsec("$_"));
	if ($error) {die "$_ loading error, $error\n";}
	$error = $temp->setbounds(29,31) if ($_ eq 'BR'); # clip at bounds
	$error = $temp->despike(0.3) if ($_ eq 'BR'); # remove unrealistic pressure spikes
	$temp->start_stop('midnight');
	$temp->window(10*60);
	$error = $temp->sample;
	#$error = $temp->vector_sample;
	if ($error) {die "$_ sampling error, $error\n";}
	my @wavg = @{$temp->wavg};
	$arrays{"$_"} = \@wavg;

	my ($maxtime, $maxval) = @{$temp->stats('max')};
	my ($mintime, $minval) = @{$temp->stats('min')};
	print OUT "$_ = ",sprintf("%5.1f",$maxval)," at ",hour_min($maxtime), 
			  " and ",sprintf("%5.1f",$minval)," at ",hour_min($mintime), "\n";
	$temp->DESTROY;	
}

#	Wind Data

my $gust_vect = Weather::Math->new;
my $avg_vect = Weather::Math->new;
my $gust = Weather::Math->new;
my $wd = Weather::Math->new;
my $was = Weather::Math->new;
#	load gusts
$error = $gust->load($RdAr -> getsec('WGS'));
if ($error) {die "WGS loading error, $error\n";}
$gust->nodata(-999);
$error = $gust->despike(20); # 20 mph gust spikes are skipped
#	load averages
$error = $was->load($RdAr -> getsec('WAS'));
if ($error) {die "WAS loading error, $error\n";}
#	load direction
$error = $wd->load($RdAr -> getsec('WD'));
if ($error) {die "WD loading error, $error\n";}
#	harmonize datasets and create vectors
$gust_vect->start_stop('midnight');
$gust_vect->nodata(-999.0);
$gust_vect->window(10*60);
$error = $gust_vect->harmonize($gust, $wd);
my ($maxtime, $maxval) = @{$gust_vect->stats('max')};
print OUT "Gust = ",sprintf("%5.1f from %5.1f",@{$maxval})," at ",hour_min($maxtime), "\n";
$error = $gust_vect->sample;
if ($error) {die "$_ sampling error, $error\n";}
my @wavg = @{$gust_vect->wavg};
$arrays{"WAVGUST"} = [map{$_->[0]}@wavg];
$arrays{"WAVDIR"} = [map{$_->[1]}@wavg];
my @avg = @{$gust_vect->avg};
my @max = @{$gust_vect->max};
$arrays{"MAXGUST"} = [map{$_->[0]}@max];
$arrays{"MAXDIR"} = [map{$_->[1]}@max];
my @min = @{$gust_vect->min};
#$avg_vect->start_stop('midnight');
#$avg_vect->nodata(-999);
#$avg_vect->window(10*60);
#$error = $avg_vect->harmonize($was, $wd);

#	Wind chill and Heat Index

my $windchill = Weather::Math->new;
$error = $windchill->load($RdAr -> getsec("WC"));
if ($error) {die "$_ loading error, $error\n";}
$windchill->start_stop('midnight');
$windchill->nodata(-999);
$windchill->window(10*60);
$error = $windchill->sample;
if ($error) {die "$_ sampling error, $error\n";}
my @WC = @{$windchill->wavg};
my ($minwc, $maxwc)=([0,999],[0,-100]) ;
for (my $i=0; $i<144; $i++) {
	if ($arrays{"TO"}->[$i] < -900 || 
	    $arrays{"WAVGUST"}->[$i] < -900) {$WC[$i] = -999; next;}
	my $wc = Weather::Math::windchill($arrays{"MAXGUST"}->[$i], $arrays{"TO"}->[$i], -999 );
	$WC[$i] = $wc;
	if ($arrays{"MAXGUST"}->[$i] < .01) {$WC[$i] = $arrays{"TO"}->[$i];}
	if ($minwc->[1] > $WC[$i]) {$minwc->[1] = $WC[$i]; $minwc->[0] = $midnight+$i*600+300;}
	if ($maxwc->[1] < $WC[$i]) {$maxwc->[1] = $WC[$i]; $maxwc->[0] = $midnight+$i*600+300;}
}
#	reset windchill array
$windchill->wavg(\@WC);
$arrays{WC} = \@WC;

#	heat index

my @Heat;
my ($minheat, $maxheat) = ([0,999],[0,-100]);
for (my $i=0; $i<144; $i++) {
	if ($arrays{TO}->[$i] < -900 || $arrays{HO}->[$i] < 0) {$Heat[$i] = -999;next;}
	$Heat[$i] = Weather::Math::heatindex($arrays{HO}->[$i], $arrays{TO}->[$i], -999 );
	if ($minheat->[1] > $Heat[$i]) {$minheat->[1] = $Heat[$i];
	                                $minheat->[0] = $midnight+$i*600+300;
	}
	if ($maxheat->[1] < $Heat[$i]) {$maxheat->[1] = $Heat[$i];
	                                $maxheat->[0] = $midnight+$i*600+300;
	}
}
$arrays{Heat} = \@Heat;
print OUT "Heat = ",sprintf("%5.1f",$maxheat->[1])," at ",hour_min($maxheat->[0]), 
		  " and ",sprintf("%5.1f",$minheat->[1])," at ",hour_min($minheat->[0]), "\n";

print OUT "WC = ",sprintf("%5.1f",$maxwc->[1])," at ",hour_min($maxwc->[0]), 
		  " and ",sprintf("%5.1f",$minwc->[1])," at ",hour_min($minwc->[0]), "\n";

#	End of extrema

print OUT "## other data\n";
printf OUT ("## begin time %s\n",hour_min($midnight));
print OUT "## Time TO  TI  HO  HI  DO  DI  WC Heat BR gust_dir gust_speed avg_dir avg_speed\n";

my $atime = $midnight;
foreach (0..143) {
	printf OUT ("%s ",hour_min($atime));
	$atime += 600;
	foreach my $q (qw/TO TI HO HI DO DI WC Heat BR/) {
		printf OUT (" %5.2f",$arrays{"$q"}->[$_]);
	}
	foreach my $q (qw/MAXDIR MAXGUST WAVDIR WAVGUST /) {
		printf OUT (" %6.1f",$arrays{"$q"}->[$_]);
	}
	print OUT "\n";
}
print OUT "## End of Data\n";

close OUT;

`cp $wdir/pack_$dashdate $wdir/packfile`;

sub prt_time {
    my $time = shift;
    my @t = localtime($time);
    my $dat = ($t[5]+1900) . "-" . ($t[4]+1) . "-" . $t[3] . " " . $t[2] . ":" . $t[1] . ":" .
$t[0];
    return $dat;
}

sub hour_min {
    my $time = shift;
    my @t = localtime($time);
    return sprintf("%02d:%02d",$t[2],$t[1]);
}

=head1 NAME

Pack_weather.pl - Read a weather archive file, create a pack file.

=head1 SYNOPSIS

This program reads a weather archive file (see Weather::Archive) and
outputs a nice packed file of values every 10 minutes. Additionally,
at no extra charge, it will clean up various problems that might
arise, de-spiking the data, picking up after resets and downtime,
etc.

=head1 DESCRIPTION

Data is read from a raw weather data file (see Weather::Archive for
details on that file) and output to a "packed", evenly interpolated
file.

	## date 4/16/2001
	## input file arch987483621
	## rainfall
	14:35  0.040
	15:05  0.040
	15:15  0.080
	15:25  0.110
	17:05  0.040
	17:15  0.040
	17:25  0.400
	17:35  0.070
	17:45  0.120
	18:05  0.040
	23:25  0.100
	## extrema data
	TO =  83.8 at 12:35 and  67.5 at 22:18
	TI =  72.9 at 19:11 and  70.3 at 14:03
	HO =  95.0 at 23:51 and  59.0 at 12:41
	HI =  78.0 at 13:12 and  65.0 at 21:23
	DO =  73.4 at 14:42 and  59.0 at 15:10
	DI =  64.4 at 12:34 and  59.0 at 20:59
	BR =  30.0 at 22:22 and  29.9 at 23:59
	Heat =  87.2 at 12:10 and  80.3 at 10:00
	WC =  84.2 at 12:07 and  64.4 at 15:21
	## other data
	## begin time 00:05
	## Time TO  TI  HO  HI  DO  DI  WC Heat BR gust_dir gust_speed avg_dir avg_speed
	00:05  76.43 -999.00 -999.00 -999.00 -999.00 -999.00 76.43 -999.00 -999.00   78.0    0.0   78.0    0.0
	00:15  76.11 70.73 76.53 70.00 69.51 60.80 76.11 76.11 29.90   78.0    0.0   78.0    0.0
	00:25  75.74 70.79 77.24 70.00 69.80 60.80 75.74 75.74 29.91   78.0    0.0   78.0    0.0
	00:35  75.70 70.70 78.00 70.00 68.00 60.80 75.70 75.70 29.91   78.0    0.0   78.0    0.0
	00:45  75.70 70.89 78.00 70.19 68.00 60.80 75.70 75.70 29.89   78.0    0.0   78.0    0.0
	00:55  75.65 70.74 78.65 70.00 68.00 60.80 75.65 75.65 29.89   78.0    0.0   78.0    0.0
	01:05  75.41 70.90 79.00 70.44 68.00 60.80 75.41 75.41 29.91   78.0    0.0   78.0    0.0
	01:15  75.10 70.90 79.49 70.00 68.00 60.80 75.10 75.10 29.91   78.0    0.0   78.0    0.0
	01:25  74.86 70.94 80.00 70.00 68.00 60.80 74.86 74.86 29.91   78.0    0.0   78.0    0.0
	01:35  74.68 70.90 80.70 70.00 69.26 60.80 74.68 74.68 29.91   78.0    0.0   78.0    0.0
	.......
	## end of data

Records beginning with ## are comments, unless they are flags. 8-)
First the rainfall data is described, as time and total for the 10
minute period centered around the given time, for any non-zero totals.
Then the extrema are given as item, max value, time, min value, time.
Finally, the majority of the data is dumped in 10 minute averages,
with times centered on the 10 minute bins.

The data types are coded as :

	TO - outside temperature
	TI - inside temperature
	HO - outside humidity
	HI - inside humidity
	DO - outside dewpoint
	DI - inside dewpoint
	WC - wind chill
	Heat - heat index
	BR - barometric pressure
	gust_dir - wind gust direction (degrees)
	gust_speed - wind gust speed
	avg_dir - average wind direction
	avg_speed - average wind speed

The time window covered is padded/truncated to fit midnight to midnight. On the ends, there may not be any data, so we output a "no data" flag, which is set to -999.
	
There is also filtering that goes on...

For rainfall :

=over

=item

rainfall spikes > 5 inches are skipped

=item

make certain that rainfall cumulative total is monotonic

=back

For wind gusts :

=over

=item

Wind spikes > 20 mph are skipped

=back

Note that the spikes are spikes in the original data, so that would
be an isolated value that is X amount larger than its neighbors. For
the wind gusts, for example, the wind would have to legitimately increase
by more than 20 mph in a time shorter than the sensor digitization
interval, which is about 10 seconds for mine. Not too likely unless
you are actually inside a tornado! The despiking is intended to remove
sensing errors I have actually encountered.

=head1 EXAMPLE

To run :

Pack_weather.pl archive-file

output will appear in pack_4-16-2001, or whatever date corresponds
to the dates within the archive file.

=head1 AUTHOR

    Alan Jackson
    October 1999
    alan@ajackson.org

=head1 BUGS

Doesn't deal well with daylight savings


=cut

