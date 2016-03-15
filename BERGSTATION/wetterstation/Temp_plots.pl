#!/usr/bin/perl -w

#	Make temperature plots

#	usage Temp_plots.pl --type <minutes/hourly/daily/weekly/monthly> 
#                       --fromdate <mm/dd/yyyy>
#                       --todate <mm/dd/yyyy>
#                       --prefix <output filename prefix>

BEGIN {push @INC, "/home/ajackson/bin/lib"}


use Carp;
use strict;
use Weather::ReadPack;
use Weather::Climate;
use GD::Graph::mixed;
use GD::Graph::Error;

#my $font = '/usr/fonts/cetus.ttf';
my $font = '/usr/share/fonts/ttf/cmbx12.ttf';

#--------------------------------------------------------------
#	Read in arguments
#--------------------------------------------------------------

my $VERSION = "1.0";

use  Getopt::Declare;

my $specification = q(  
[strict]
[pvtype: date	/\d{1,2}\/\d{1,2}\/\d{4}/ {reject if (split('/',$_VAL_))[0]>12;
                                      	   reject if (split('/',$_VAL_))[1]>31;
											} ]

--type <type:/minutes|hourly|daily|weekly|monthly/>	output type (must be minutes, hourly, daily, weekly, or monthly) [required]

--prefix <prefix:s>	output filename prefix [required]

--todate <todate:date>	ending date (mm/dd/yyyy) [required]

--fromdate <fromdate:date>	starting date (mm/dd/yyyy) [required]

);

my $args = new Getopt::Declare($specification);

die if !$args;

my @range = ($args->{'--fromdate'}, $args->{'--todate'});

my %args;
$args{'type'} = $args->{'--type'};
$args{'prefix'} = $args->{'--prefix'};
$args{'fromdate'} = $args->{'--fromdate'};
$args{'todate'} = $args->{'--todate'};

#--------------------------------------------------------------
#	End of Read in arguments
#--------------------------------------------------------------


#--------------------------------------------------------------
#	Get Climatological data
#--------------------------------------------------------------

my @highestT = Weather::Climate::getarray('highestT',@range,$args{type},'max');
my @lowestT = Weather::Climate::getarray('lowestT',@range, $args{type},'min');
my @AvgLowT = Weather::Climate::getarray('AvgLowT',@range, $args{type},'avg');
my @AvgHighT = Weather::Climate::getarray('AvgHighT',@range, $args{type},'avg');
my @afternoon_humidity = Weather::Climate::getarray('afternoon_humidity',@range, $args{type},'max');
my @morning_humidity = Weather::Climate::getarray('morning_humidity',@range, $args{type},'min');

#--------------------------------------------------------------
#	Get Weather data
#--------------------------------------------------------------

my $RdAr = Weather::ReadPack->new(@range, ['Time','gust_speed','TO','HO','WC','Heat','DO','extrema', 'BR'], $args{type});

my @extrema = @{$RdAr->get('extrema',0)};

#	Min/Max and times
my %extrema;
foreach (@extrema) {
	if ($_->[3] eq 'Gust') {
		# skip
	}
	else {
		if (!defined $extrema{$_->[3]}) {
			$extrema{$_->[3]} = [$_->[4], $_->[5],$_->[6], $_->[7]];
		}
		else {
			if ($extrema{$_->[3]}->[0] < $_->[4]) {
				$extrema{$_->[3]} = [$_->[4], $_->[5],
						 $extrema{$_->[3]}->[2], $extrema{$_->[3]}->[3]];
			}
			if ($extrema{$_->[3]}->[2] > $_->[6]) {
				$extrema{$_->[3]} = [$extrema{$_->[3]}->[0], $extrema{$_->[3]}->[1],
									$_->[6], $_->[7]];
			}
		}
	}
}

open(TMAX, ">".$args{prefix}."_tmaxmin") or die $!;
print TMAX "<b>Maximum Temperature of $extrema{'TO'}->[0] deg F recorded at $extrema{'TO'}->[1]</b>\n";
print TMAX "<b>Minimum Temperature of $extrema{'TO'}->[2] deg F recorded at $extrema{'TO'}->[3]</b>\n";
print TMAX "<b>Average climatological Low of ",sprintf("%4.1f",avg(\@AvgLowT))," deg F, High of ", avg(\@AvgHighT)," deg F</b>\n";
close TMAX;

my $tmax = $extrema{'TO'}->[0];
my $tmin = $extrema{'TO'}->[2];

my $highestT = max(\@highestT);
my $lowestT = min(\@lowestT);

#--- time
my $Time = $RdAr -> get('Time',0);

#--- outside temperature
my $TO = $RdAr -> get('TO',0);

#--- humidity
my $HO = $RdAr -> get('HO',0);

#--- pressure
my $Press = $RdAr -> get('BR',0);

#--- outside windchill and heat index
my $WC = $RdAr -> get('WC',0);
my $Heat = $RdAr -> get('Heat',0);
my ($minchill, $maxheat)= ($extrema{'WC'}->[2], $extrema{'Heat'}->[0]);

if ($minchill < $tmin) {$tmin = $minchill;}
if ($maxheat > $tmax) {$tmax = $maxheat;}

#--- outside dewpoint
my $DO = $RdAr -> get('DO');
if ($extrema{'DO'}->[2] <  $tmin) {$tmin = $extrema{'DO'}->[2];}

#--- build arrays for plotting
for (my $i=0; $i<@$Time; $i++) {
	if ($TO->[$i] ==-999) {$TO->[$i] = undef;}
	if ($DO->[$i] ==-999) {$DO->[$i] = undef;}
	if ($HO->[$i] ==-999) {$HO->[$i] = 0;}
	if ($Press->[$i] <=29) {$Press->[$i] = undef;}
	if ($WC->[$i] ==-999) {$WC->[$i] = undef;}
	if ($Heat->[$i] ==-999) {$Heat->[$i] = undef;}
}

#	Plot bounds

#	Do I show the record high/low? Only if within 10 degrees of actual
my $showMax = 0;
my $showMin = 0;
for (my $i=0; $i<= $#highestT; $i++) {
	next if !defined $TO->[$i];
	if ( ($highestT[$i] - $TO->[$i]) <= 10) {$showMax = 1;} 
	if ( ($TO->[$i] - $lowestT[$i] ) <= 10) {$showMin = 1;} 
}

$tmax = 10*int(($tmax+10)/10);
$tmax = 10*int(($highestT+10)/10) if $showMax;
$tmin = 10*int(($tmin-10)/10);
$tmin = 10*int(($lowestT-10)/10) if $showMin;

#---------------------------------------------------------------
#		Plot
#---------------------------------------------------------------

#	Temperature plot

my $my_graph = GD::Graph::lines->new(700,300);
 $GD::Graph::Error::Debug = 6;

my $labelskip = 12;
if ($args{type} eq 'daily') {
	$labelskip = 4;
}
elsif ($args{type} eq 'weekly') {
	$labelskip = 3;
}
elsif ($args{type} eq 'monthly') {
}

$labelskip = int(@$Time/5);

$Time->[5*$labelskip] = ""; # drop last label

$my_graph->set(
	transparent => 0,
	x_label_skip => $labelskip,
	types => [qw(lines lines lines lines lines lines lines lines lines)],
	long_ticks => 1,
	line_width => 2,
	x_label => 'Time',
	y_label => 'Degrees F',
	y_max_value => $tmax,
	y_min_value => $tmin,
	title => "Temperature Data from ".join(' to ',@range),
);

if ($args{fromdate} eq $args{todate}) {
	$my_graph->set(title => "Temperature Data for $args{fromdate}");
}
$my_graph->set( line_types => [1, 1, 1, 1, 3, 3, 3, 3, ] );
$my_graph->set_values_font("$font",12);
$my_graph->set_x_axis_font("$font",10);
$my_graph->set_y_axis_font("$font",10);
$my_graph->set_x_label_font("$font",12);
$my_graph->set_y_label_font("$font",12);
$my_graph->set_title_font("$font",14);

$my_graph->set_legend_font("$font",8);
my @legend = ("Wind Chill","Heat Idx","Temp","Dew Pt","Avg Low","Avg Hi",);
push @legend, "Rec Hi" if $showMax;
push @legend, "Rec Low" if $showMin;
$my_graph->set_legend(@legend);

my @data = ($Time, $WC, $Heat, $TO, $DO, \@AvgLowT, \@AvgHighT,);
push @data, \@highestT if $showMax;
push @data, \@lowestT if $showMin;

my $gd = $my_graph->plot(\@data);
open(IMG, ">".$args{prefix}."_Temperature.png") or die $!;
binmode IMG;
print IMG $gd->png;
close IMG;

print $my_graph->error,"\n";

#----------------------------
#	Humidity plot
#----------------------------

my $my_graph2 = GD::Graph::mixed->new(700,300);

$my_graph2->set(
	transparent => 0,
	x_label_skip => $labelskip,
	types => [qw(area lines lines)],
	line_width => 2,
	long_ticks => 1,
	x_label => 'Time',
	y_label => 'Percent',
	y_max_value => 100,
	y_min_value => 0,
	title => "Relative Humidity Data from ".join(' to ',@range),
);
if ($args{fromdate} eq $args{todate}) {
	$my_graph2->set(title => "Relative Humidity Data for $args{fromdate}");
}
$my_graph2->set( line_types => [1, 3, 3, ] );
$my_graph2->set_values_font("$font",12);
$my_graph2->set_x_axis_font("$font",10);
$my_graph2->set_y_axis_font("$font",10);
$my_graph2->set_x_label_font("$font",12);
$my_graph2->set_y_label_font("$font",12);
$my_graph2->set_legend_font("$font",10);
$my_graph2->set_title_font("$font",14);
$my_graph2->set_legend(("Humidity","Avg Morning","Avg Afternoon",));

$gd = $my_graph2->plot([$Time, $HO, \@morning_humidity, \@afternoon_humidity]);
open(IMG, ">".$args{prefix}."_Humidity.png") or die $!;
binmode IMG;
print IMG $gd->png;
close IMG;

#----------------------------
#	Pressure plot
#----------------------------

my $my_graph3 = GD::Graph::mixed->new(700,300);
my $bmax = int(10*$extrema{'BR'}->[0]+1)/10;
my $bmin = int(10*$extrema{'BR'}->[2]-1)/10;

$my_graph3->set(
	transparent => 0,
	x_label_skip => $labelskip,
	types => [qw( lines )],
	line_width => 2,
	long_ticks => 1,
	x_label => 'Time',
	y_label => 'in Hg',
	y_max_value => $bmax,
	y_min_value => $bmin,
	title => "Barometric Pressure Data from ".join(' to ',@range),
);
if ($args{fromdate} eq $args{todate}) {
	$my_graph3->set(title => "Barometric Pressure Data for $args{fromdate}");
}
$my_graph3->set( line_types => [1, ] );
$my_graph3->set_values_font("$font",12);
$my_graph3->set_x_axis_font("$font",10);
$my_graph3->set_y_axis_font("$font",10);
$my_graph3->set_x_label_font("$font",12);
$my_graph3->set_y_label_font("$font",12);
$my_graph3->set_legend_font("$font",10);
$my_graph3->set_title_font("$font",14);

$gd = $my_graph3->plot([$Time, $Press, ]);
open(IMG, ">".$args{prefix}."_Pressure.png") or die $!;
binmode IMG;
print IMG $gd->png;
close IMG;

#-------------------------------------------------

sub avg {
	my $arr = shift;
	my $sum=0;
	foreach (@$arr) {$sum+=$_ if defined $_;}
	return $sum/@$arr;
}
sub max {
	my $arr = shift;
	my $max = $arr->[0];
	foreach (@$arr) { if (defined $_) {$max = $max > $_ ? $max : $_;}}
	return $max;
}
sub min {
	my $arr = shift;
	my $min = $arr->[0];
	foreach (@$arr) { if (defined $_) {$min = $min < $_ ? $min : $_;}}
	return $min;
}
