#!/usr/bin/perl -w

#	Make wind plots

#	usage Wind_plots.pl --type <minutes/hourly/daily/weekly/monthly> 
#                       --fromdate <mm/dd/yyyy>
#                       --todate <mm/dd/yyyy>
#                       --prefix <output filename prefix>
#                       --style <rose/tadpole>
#						--number <number of roses>



BEGIN {push @INC, "/home/ajackson/bin/lib"}

use Carp;
use strict;
use Weather::ReadPack;
use Weather::Climate;
use Weather::Math;
use GD::Graph::mixed;
use GD::Graph::rose;
use Date::Calc qw(
             Date_to_Days
             Delta_Days
             Add_Delta_Days
			 Add_Delta_DHMS
         );

my $font = '/usr/share/fonts/ttf/cmbx12.ttf';
$font = '/usr/fonts/cetus.ttf';

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

--style <style:/rose|tadpole/>	Plot style (rose or tadpole) [required]

--number <number:+i>	Number of roses

--prefix <prefix:s>	output filename prefix [required]

--todate <todate:date>	ending date (mm/dd/yyyy) [required]

--fromdate <fromdate:date>	starting date (mm/dd/yyyy) [required]

);

my $args = new Getopt::Declare($specification);

die if !$args;

my @range = ($args->{'--fromdate'}, $args->{'--todate'});
if (!defined $args->{'--number'} || $args->{'--number'} < 1) {$args->{'--number'} = 1;} # default value


my %args;
$args{'type'} = $args->{'--type'};
$args{'style'} = $args->{'--style'};
$args{'prefix'} = $args->{'--prefix'};
$args{'number'} = $args->{'--number'};
$args{'fromdate'} = $args->{'--fromdate'};
$args{'todate'} = $args->{'--todate'};

#--------------------------------------------------------------
#	End of Read in arguments
#--------------------------------------------------------------

#--------------------------------------------------------------
#	Get Climatological data
#--------------------------------------------------------------

my @wind = Weather::Climate::getarray('wind_speed',@range, $args{type},'max');

#--------------------------------------------------------------
#	Get Weather data
#--------------------------------------------------------------

my $RdAr = Weather::ReadPack->new(@range, ['Time','gust_dir','gust_speed','extrema'], $args{type});

my ($dir, $speed, $Time, $hour);

if ($args{type} eq 'daily' || $args{type} eq 'weekly' || $args{type} eq 'monthly') {
	# need only use the extrema
	my @extrema = @{$RdAr->get('extrema',0)};
	foreach (@extrema) {
		if ($_->[3] eq 'Gust') {
			push @$dir, $_->[5];
			push @$speed, $_->[4];
			push @$Time, sprintf("%2d/%02d/%4d",$_->[1],$_->[2],$_->[0]);
			push @$hour, $_->[6];
		}
	}
	#	depopulate if necessary
	if ($args{type} eq 'weekly') {
		($speed, $dir, $Time) = maxmodulo($speed, $dir, $Time, 7);
	}
}
else { # use the detailed data

	#--- gust direction 
	$dir = $RdAr->get('gust_dir',0);

	#--- gust speed 
	$speed = $RdAr->get('gust_speed',0);

	#--- time
	$Time = $RdAr -> get('Time',0);
}

#	Find maxima

my ($maxW, $minW) = (5,0);
open(WMAX,">$args{prefix}"."_wmax") || die "Can't open $args{prefix}"."_wmax. $!\n";
my $interval = @$Time/$args{number};
if ($args{number} > 1) {
	for (my $i=1; $i<=$args{number}; $i++) {
		my @temp = map {$_} @{$speed}[($i-1)*$interval..($i*$interval-1)];
		my ($max, $imax) = @{Weather::Math::imax(@temp)};
		$maxW = $max>$maxW ? $max : $maxW;
		$imax += ($i-1)*$interval;
		printf WMAX ("<b>Maximum Gust of %6.2f mph from %s at %s <br></b>\n", $max, Weather::Math::compass($dir->[$imax]), $Time->[$imax]);
	}
}
else {
	my ($max, $imax) = @{Weather::Math::imax(@$speed)};
		$maxW = $max;
	printf WMAX ("<b>Maximum Gust of %6.2f mph from %s at %s <br></b>\n", $max, Weather::Math::compass($dir->[$imax]), $Time->[$imax]);
}
printf WMAX ("<b>Climatological average windspeed = %6.2f mph <br></b>\n",avg(\@wind));

close WMAX;

$maxW = 5*int(($maxW+4.99)/5);

#---------------------------------------------------------------
#		Plot
#---------------------------------------------------------------

#	Tadpole plot

if ($args{style} eq 'tadpole') {

	my $my_graph = GD::Graph::linespoints->new(700,300);

	my $labelskip = int(@$Time/5);
	$Time->[5*$labelskip] = ""; # drop last label

	$my_graph->set(
		transparent => 0,
		x_label_skip => $labelskip,
		types => [qw(lines lines)],
		long_ticks => 1,
		line_width => 2,
		x_label => 'Time',
		y_label => 'Wind Speed',
		y_max_value => $maxW,
		y_min_value => $minW,
		title => "Wind Data from ".join(' to ',@range),
		dclrs => [ 'yellow', 'red', 'blue' ],
	);

	if ($args{fromdate} eq $args{todate}) {
		$my_graph->set(title => "Wind Data for $args{fromdate}");
	}

	$my_graph->set( line_types => [0, ] );
	$my_graph->set_values_font("$font",12);
	$my_graph->set_x_axis_font("$font",10);
	$my_graph->set_y_axis_font("$font",10);
	$my_graph->set_x_label_font("$font",12);
	$my_graph->set_y_label_font("$font",12);
	$my_graph->set_title_font("$font",14);

	$my_graph->set( markers => [ 0, 0 ] );
	$my_graph->set( line_types => [1, 1 ] );

	$my_graph->set_legend_font("$font",10);
	$my_graph->set_legend(("", "Historical Average", ));

	my $gd = $my_graph->plot([$Time, $speed, \@wind ]);

	#	Now add in the tadpoles

	my @pnts = $my_graph->get_hotspot(1);
	for (my $i=0;$i<=$#{$Time};$i++) {
		if (defined $speed->[$i] && $speed->[$i] > .01) {
			tadpole($gd, $pnts[$i][3], $pnts[$i][4], 1, 5, $dir->[$i] );
		}
	}

	open(IMG, ">".$args{prefix}."_Wind.png") or die $!;
	binmode IMG;
	print IMG $gd->png;
	close IMG;

}
else { # rose plots
	#	First split it up. calculate frequencies in each direction and gust.
	my $interval = int($#{$Time}/$args{number});
	my @angs;
	map {$angs[$_] = 10*$_} (0..35);
	my @title;
	for (my $i=0; $i<$args{number}; $i++) {
		my @freq;
		my @gust;
		map {$gust[$_] = 0;} (0..35);
		map {$freq[$_] = 0;} (0..35);
		#	round direction to 10 degree bins
		for (my $j=$interval*$i; $j<$interval*($i+1); $j++) {
			$freq[int(0.1*$dir->[$j])]++;
			$gust[int(0.1*$dir->[$j])] = $speed->[$j] if
				$speed->[$j] > $gust[int(0.1*$dir->[$j])];
		}

		my $test=0;
		map {$test+=$_;} @freq;
		if ($test == 0) { # no data condition
			unlink $args{prefix}."_rose_$i".".png";
			next;
		}

		$title[$i] = $Time->[$interval*$i]." until ".$Time->[$interval*($i+1)];

		my $rose = new GD::Graph::rose( 150, 150 );
		$rose->set( 
			title => $title[$i],

			bgclr => "white",
			fgclr => "dblue",
			transparent => 0,
		);
		$rose->set_legend("Gusts","Frequency");
		#my $gd = $rose->plot([\@angs, \@gust, \@freq]);
		#my $gd = $rose->plot([\@angs, \@gust, ]);
		my $gd = $rose->plot([\@angs, \@freq, ]);
		open(IMG, ">".$args{prefix}."_rose_$i".".png") or die $!;
		binmode IMG;
		print IMG $gd->png;
	}
}

#-------------------------------------------------

sub avg {
	my $arr = shift;
	my $sum=0;
	foreach (@$arr) {$sum+=$_ if defined $_;}
	return $sum/@$arr;
}

sub tadpole {
	my ($self, $xp, $yp, $mclr, $size, $ang ) = @_;
	my $len = 6 * $size;
	$ang = 3.14159*$ang/180;
	my $dx = $len*sin($ang);
	my $dy = -1*$len*cos($ang);
	$self->arc( $xp, $yp, 2 * $size,
						 2 * $size, 0, 360, $mclr );
	$self->line( $xp, $yp, $xp+$dx, $yp+$dy, $mclr );
}

sub isdate {
	my $test = shift;
	my @test = split(/\//,$test);
	if (!defined $test[0] || $test[0] < 1 || $test[0] > 12) {return 0;}
	if (!defined $test[1] || $test[1] < 1 || $test[1] > 31) {return 0;}
	if (!defined $test[2] || $test[2] < 1 || $test[2] > 2100) {return 0;}
}

#	find the max speed in constant width windows

sub maxmodulo {
	my ($speed, $dir, $Time, $modulo) = @_;
	my @output = (); my @mdir; my @mtime;
	my $mdir; my $mtime;
	my $max = 0; my $n=0; my $i=0;
	foreach (@{$speed}) { 
		if ($_>$max) {
			$max = $_;
			$mdir = $dir->[$i];
			$mtime = $Time->[$i];
		}
		$n++;
		if ($i%$modulo == 0) {
			push @output, $max;
			push @mdir, $mdir;
			push @mtime, $mtime;
			$n = 0; $max = 0;
		}
		$i++;
	}
	if ($n>0) { 
		push @output, $max;
		push @mdir, $mdir;
		push @mtime, $mtime;
	}
	return \@output, \@mdir, \@mtime;
}

sub prttime {
	my $time = shift;
	my @t = localtime($time);
	return sprintf("%d/%d/%d %d:%02d",$t[4]+1, $t[3], $t[5]+1900, $t[2], $t[1] );
}

