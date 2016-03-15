#!/usr/bin/perl -w

#	Make temperature plots with Highs and Lows

#	usage Temp_plots.pl --type <daily/weekly/monthly> 
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

--type <type:/daily|weekly|monthly/>	output type (must be daily, weekly, or monthly) [required]

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

my $RdAr = Weather::ReadPack->new(@range, ['Time','gust_speed','TO','HO','WC','Heat','DO','extrema'], $args{type});

my @extrema = @{$RdAr->get('extrema',0)};

#	Min/Max and times
my %extrema;
foreach (@extrema) {
	my $date = $_->[1] . "/" . $_->[2] . "/" . $_->[0];
	if ($_->[3] eq 'Gust') {
		# skip
	}
	else {
		if (!defined $extrema{$_->[3]}) {
			$extrema{$_->[3]} = [$_->[4], $_->[5], $_->[6], $_->[7], $date, $date];
		}
		else {
			if ($extrema{$_->[3]}->[0] < $_->[4]) { # min
				$extrema{$_->[3]} = [$_->[4], $_->[5],
						 $extrema{$_->[3]}->[2], $extrema{$_->[3]}->[3], $date, $extrema{$_->[3]}->[5]];
			}
			if ($extrema{$_->[3]}->[2] > $_->[6]) { # max
				$extrema{$_->[3]} = [$extrema{$_->[3]}->[0], $extrema{$_->[3]}->[1],
									$_->[6], $_->[7], $extrema{$_->[3]}->[4], $date];
			}
		}
	}
}

open(TMAX, ">".$args{prefix}."_tmaxmin") or die $!;
print TMAX "<b>Maximum Temperature of $extrema{'TO'}->[0] deg F recorded at $extrema{'TO'}->[1] on $extrema{'TO'}->[4]</b>\n";
print TMAX "<b>Minimum Temperature of $extrema{'TO'}->[2] deg F recorded at $extrema{'TO'}->[3] on $extrema{'TO'}->[5]</b>\n";
print TMAX "<b>Average climatological Low of ",sprintf("%4.1f",avg(\@AvgLowT))," deg F, High of ", sprintf("%4.1f",avg(\@AvgHighT))," deg F</b>\n";
close TMAX;

#my $tmax = $extrema{'TO'}->[0];
#my $tmin = $extrema{'TO'}->[2];

my $highestT = max(\@highestT);
my $lowestT = min(\@lowestT);

#if ( ($highestT - $tmax) > 10 ) {$highestT = undef;}
#if ( ($tmin - $lowestT) > 10 ) {$lowestT = undef;}

#--- time
my $Time = $RdAr -> get('Time',0);

my ($TOmax, $TOmin, $HOmin, $HOmax, $DOmin, $DOmax, $WC, $Heat, $Barmax, $Barmin);
my ($maxT, $maxTO, $minT, $minTO) = (-100, -100, 200, 200);


foreach (@extrema) {
	if ($_->[3] eq "TO") {push @$TOmax, $_->[4] ; push @$TOmin, $_->[6] ;}
	if ($_->[3] eq "TO") {$maxT = max($maxT,$_->[4]); $minT = min($minT,$_->[6]);}
	if ($_->[3] eq "TO") {$maxTO = max($maxTO,$_->[4]); $minTO = min($minTO,$_->[6]);}
	if ($_->[3] eq "Heat") {push @$Heat, $_->[4] ;}
	if ($_->[3] eq "Heat") {$maxT = max($maxT,$_->[4]);}
	if ($_->[3] eq "HO") {push @$HOmax, $_->[4] ; push @$HOmin, $_->[6] ;}
	if ($_->[3] eq "DO") {push @$DOmax, $_->[4] ; push @$DOmin, $_->[6] ;}
	if ($_->[3] eq "DO") {$maxT = max($maxT,$_->[4]); $minT = min($minT,$_->[6]);}
	if ($_->[3] eq "WC") {push @$WC, $_->[6] ;} 
	if ($_->[3] eq "WC") {$minT = min($minT,$_->[6]);}
	if ($_->[3] eq "BR") {push @$Barmax, $_->[4] ; push @$Barmin, $_->[6] ;}

}

#--- build arrays for plotting
for (my $i=0; $i<@$Time; $i++) {
	if ($TOmax->[$i] ==-999) {$TOmax->[$i] = undef;}
	if ($DOmax->[$i] ==-999) {$DOmax->[$i] = undef;}
	if ($HOmax->[$i] ==-999) {$HOmax->[$i] = undef;}
	if ($Barmax->[$i] ==-999) {$Barmax->[$i] = undef;}
	if ($TOmin->[$i] ==-999) {$TOmin->[$i] = undef;}
	if ($DOmin->[$i] ==-999) {$DOmin->[$i] = undef;}
	if ($HOmin->[$i] ==-999) {$HOmin->[$i] = undef;}
	if ($Barmin->[$i] ==-999) {$Barmin->[$i] = undef;}
	if ($WC->[$i] <-100) {$WC->[$i] = undef;}
	if ($Heat->[$i] <-100) {$Heat->[$i] = undef;}
}
my (@mins, @maxs);
@mins = ($TOmin, $DOmin, $HOmax, $Barmin, $WC);
@maxs = ($TOmax, $DOmax, $HOmin, $Barmax, $Heat);

#	if weekly or monthly, combine values

if ($args{type} eq 'monthly') {
	########## doesn't work yet...
}
if ($args{type} eq 'weekly') {
	foreach my $var (@mins) {
		my @output = ();
		my $min = 200; my $n=0; my $i=1;
		foreach (@{$var}) { 
			if ($_ > -999) {
				$min = $_ < $min ? $_ : $min;
				$n++;
			}
			if ($i%7 == 0) {
				$min = $n ? $min : -999;
				push @output, $min;
				$n = 0; $min = 200;
			}
			$i++;
		}
		if ($n>0) {push @output, $n ? $min : -999;}
		@{$var} = @output;
	}
}


if ($args{type} eq 'monthly') {
	########## doesn't work yet...
}
if ($args{type} eq 'weekly') {
	foreach my $var (@maxs) {
		my @output = ();
		my $max = -200; my $n=0; my $i=1;
		foreach (@{$var}) { 
			if ($_ > -999) {
				$max = $_ > $max ? $_ : $max;
				$n++;
			}
			if ($i%7 == 0) {
				$max = $n ? $max : -999;
				push @output, $max;
				$n = 0; $max = -200;
			}
			$i++;
		}
		if ($n>0) {push @output, $n ? $max : -999;}
		@{$var} = @output;
		#$var = \@output;
	}
}


#	Plot bounds

$maxT = 10*int(($maxT+10)/10);
$minT = 10*int(($minT-10)/10);

#---------------------------------------------------------------
#		Plot
#---------------------------------------------------------------

#	Temperature plot

my $my_graph = GD::Graph::lines->new(700,300);

my $labelskip = int(@$Time/5);

$Time->[5*$labelskip] = ""; # drop last label

$my_graph->set(
	transparent => 0,
	x_label_skip => $labelskip,
	types => [qw(lines lines lines lines lines lines lines lines)],
	long_ticks => 1,
	line_width => 2,
	x_label => 'Date',
	y_label => 'Degrees F',
	y_max_value => $maxT,
	y_min_value => $minT,
	title => "Temperature Data from ".join(' to ',@range),
	dclrs => [ qw(green yellow red blue pink lblue orange cyan) ]
);

$my_graph->set( line_types => [1, 1, 1, 1, 3, 3, 3, 3, ] );
$my_graph->set_values_font("$font",12);
$my_graph->set_x_axis_font("$font",10);
$my_graph->set_y_axis_font("$font",10);
$my_graph->set_x_label_font("$font",12);
$my_graph->set_y_label_font("$font",12);
$my_graph->set_title_font("$font",14);

$my_graph->set_legend_font("$font",8);
$my_graph->set_legend(("Wind Chl","Heat Idx","Hi","Low","Avg Hi","Avg Low","Rec Hi", "Rec Low"));

my $gd = $my_graph->plot([$Time, $WC, $Heat, $TOmax, $TOmin, \@AvgHighT, \@AvgLowT, \@highestT, \@lowestT ]);

#	color between hi and lo lines

my @hipnts = $my_graph->get_hotspot(3);
my @lopnts = $my_graph->get_hotspot(4);

my $numlines = $#hipnts;
my $inc = 1;
if ($numlines > 100) {
	$inc = int($numlines/100 + 1)
}

for (my $i=0; $i<=$numlines; $i+=$inc) {
	$gd->line($hipnts[$i][1],$hipnts[$i][2],
	             $hipnts[$i][1],$lopnts[$i][2],3);
}

open(IMG, '>'.$args{prefix}.'_Temperature.png') or die $!;
binmode IMG;
print IMG $gd->png;
close IMG;

#-------------------------------
#	Humidity plot
#-------------------------------

my $my_graph2 = GD::Graph::mixed->new(700,350);

$my_graph2->set(
	transparent => 0,
	x_label_skip => $labelskip,
	#types => [qw(bars bars lines lines)],
	types => [qw(area area lines lines)],
	line_width => 2,
	long_ticks => 1,
	x_label => 'Date',
	y_label => 'Percent',
	y_max_value => 100,
	y_min_value => 0,
	title => "Relative Humidity Data from ".join(' to ',@range),
);
$my_graph2->set( line_types => [1, 1, 3, 3, ] );
$my_graph2->set_values_font("$font",12);
$my_graph2->set_x_axis_font("$font",10);
$my_graph2->set_y_axis_font("$font",10);
$my_graph2->set_x_label_font("$font",12);
$my_graph2->set_y_label_font("$font",12);
$my_graph2->set_legend_font("$font",10);
$my_graph2->set_title_font("$font",14);
$my_graph2->set_legend(("Max Humidity","Min Humidity","Avg Max","Avg Min",));

$gd = $my_graph2->plot([$Time, $HOmax, $HOmin, \@morning_humidity, \@afternoon_humidity]);
open(IMG, '>'.$args{prefix}.'_Humidity.png') or die $!;
binmode IMG;
print IMG $gd->png;
close IMG;

#	Pressure plot

my $my_graph3 = GD::Graph::lines->new(700,300);
my $bmax = 0; my $bmin = 100;
foreach (@$Barmin) {
	next if $_ < 0;
	$bmin = $_ if $_ < $bmin;
}
foreach (@$Barmax) {
	next if $_ < 0;
	$bmax = $_ if $_ > $bmax;
}
$bmax = int(10*$bmax+1)/10;
$bmin = int(10*$bmin-1)/10;

$my_graph3->set(
	transparent => 0,
	x_label_skip => $labelskip,
	types => [qw(lines )],
	long_ticks => 1,
	line_width => 2,
	x_label => 'Date',
	y_label => 'Inches Hg',
	y_max_value => $bmax,
	y_min_value => $bmin,
	title => "Pressure Data from ".join(' to ',@range),
);
$my_graph3->set( line_types => [1, 1] );
$my_graph3->set_values_font("$font",12);
$my_graph3->set_x_axis_font("$font",10);
$my_graph3->set_y_axis_font("$font",10);
$my_graph3->set_x_label_font("$font",12);
$my_graph3->set_y_label_font("$font",12);
$my_graph3->set_legend_font("$font",10);
$my_graph3->set_title_font("$font",14);

$my_graph3->set_legend_font("/usr/fonts/cetus.ttf",10);
$my_graph3->set_legend(("Maximum","Minimum",));

$gd = $my_graph3->plot([$Time, $Barmin, $Barmax]);

#	color between hi and lo lines

@hipnts = $my_graph3->get_hotspot(1);
@lopnts = $my_graph3->get_hotspot(2);

$numlines = $#hipnts;
$inc = 1;
if ($numlines > 200) {
	$inc = int($numlines/200 + 1)
}

for (my $i=0; $i<=$numlines; $i+=$inc) {
	next if (!defined $hipnts[$i][2] || !defined $lopnts[$i][2]);
	$gd->line($hipnts[$i][1],$hipnts[$i][2],
	             $hipnts[$i][1],$lopnts[$i][2],3);
}
$gd->line($hipnts[$numlines][3],$hipnts[$numlines][4],
		  $hipnts[$numlines][3],$lopnts[$numlines][4],3);

open(IMG, '>'.$args{prefix}.'_Pressure.png') or die $!;
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
	if (ref $arr eq "ARRAY") {
		my $max = $arr->[0];
		foreach (@$arr) { if (defined $_) {$max = $max > $_ ? $max : $_;}}
		return $max;
	}
	else {
		my $max = $arr;
		foreach (@_) { if (defined $_) {$max = $max > $_ ? $max : $_;}}
		return $max;
	}
}
sub min {
	my $arr = shift;
	if (ref $arr eq "ARRAY") {
		my $min = $arr->[0];
		foreach (@$arr) { if (defined $_) {$min = $min < $_ ? $min : $_;}}
		return $min;
	}
	else {
		my $min = $arr;
		foreach (@_) { if (defined $_) {$min = $min < $_ ? $min : $_;}}
		return $min;
	}
}
