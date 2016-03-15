#!/usr/bin/perl -w

#	Make rain plots

#	usage Rain_plots.pl --type <minutes/hourly/daily/weekly/monthly> 
#                       --fromdate <mm/dd/yyyy>
#                       --todate <mm/dd/yyyy>
#                       --prefix <output filename prefix>
#                       --sum_rate <sum/rate>



BEGIN {push @INC, "/home/ajackson/bin/lib"}

use Carp;
use strict;
use Weather::ReadPack;
use Weather::Climate;
use GD::Graph::mixed;
use Date::Calc qw(
             Date_to_Days
             Delta_Days
             Add_Delta_Days
			 Add_Delta_DHMS
         );

my $font = '/usr/share/fonts/ttf/cmbx12.ttf';

#--------------------------------------------------------------
#	Read in arguments
#--------------------------------------------------------------

my $VERSION = "1.0";

my @sargs = qw /h help v version/;
my @args = qw /type fromdate todate sum_rate prefix/;
my @argdoc = ('<minutes/hourly/daily/weekly/monthly>',
              '<mm/dd/yyyy>',
			  '<mm/dd/yyyy>',
			  '<sum/rate>',
			  '<output filename prefix>',);

if (@ARGV && ($ARGV[0] eq "-v" || $ARGV[0] eq "--version")) {
	print "$0 $VERSION 09/06/01\n";
	exit;
}

sub usage {"Usage: $0 [-h -v --help --version] ",(map{" --$args[$_] $argdoc[$_]"}(0..$#args)),"\n"}

$0 =~ s!^.*/!!; die usage unless (@ARGV && $ARGV[0] ne "-h" && $ARGV[0] ne "--help"); 
if (@ARGV%2 == 1) {die usage;} # check for even number of parameters
@ARGV = map {$_=~s/^--//;$_} @ARGV; # strip -- from paramaters
my %args = @ARGV; # make hash

#	Look for invalid parameters
my %testargs = map {($_,1)}@args;

foreach (keys %args) {
	next if (defined $testargs{$_});
	die usage;
}

#	Valid --type?

if (defined $args{type}) {
	%testargs = map {($_,1)} qw /minutes hourly daily weekly monthly/;
	die usage if !defined $testargs{$args{type}};
}
else {
	$args{type} = "daily"; # default value
}

my @range = ($args{fromdate}, $args{todate});

#--------------------------------------------------------------
#	End of Read in arguments
#--------------------------------------------------------------

#--------------------------------------------------------------
#	Get Climatological data
#--------------------------------------------------------------

my @precip = Weather::Climate::getarray('precip',@range, $args{type},'sum');

#--------------------------------------------------------------
#	Get Weather data
#--------------------------------------------------------------

my $RdAr = Weather::ReadPack->new(@range, ['Time','TO','HO','DO','rainfall'], $args{type});

#--- Rain Total
my $RT = $RdAr->get('rainfall',0);

#--- time
my $Time = $RdAr -> get('Time',0);

my $Total = 0;
foreach (@{$RT}){
	$Total += $_;
}

open(RAIN,">".$args{prefix}."_raintot") || die "Can't open raintot. $!\n";
if ($args{fromdate} eq $args{todate}) {
	print RAIN "<b>Total rainfall for $args{fromdate} was $Total inches</b>\n";
}
else {
	print RAIN "<b>Total rainfall from ",join(' to ',@range)," was $Total inches</b>\n";
}
close RAIN;

#---------------------------------------------------------------
#		If a Sum plot, sum up the values
#---------------------------------------------------------------

my $moretitle = "";
my ($sumr, $sumc) = (0,0);
if (defined $args{sum_rate} && $args{sum_rate} eq 'sum') {
	for (my $i=0; $i<=$#{$Time}; $i++) {
		$sumr += $RT->[$i];
		$sumc += $precip[$i]; # climate avg
		$RT->[$i] = $sumr;
		$precip[$i] = $sumc;
	}
	$moretitle = "Cumulative";
}

#---------------------------------------------------------------
#		Plot
#---------------------------------------------------------------

#	Rainfall plot

my $plottype = 'bars';
if (@$Time > 180) {$plottype = 'area';}

my $my_graph = GD::Graph::mixed->new(700,300);

my $labelskip = int(@$Time/5);

$Time->[5*$labelskip] = ""; # drop last label

$my_graph->set(
	transparent => 0,
	x_label_skip => $labelskip,
	types => [$plottype, 'lines'],
	long_ticks => 1,
	line_width => 2,
	x_label => 'Time',
	y_label => 'Inches',
	title => "$moretitle Rainfall Data from ".join(' to ',@range),
);

if ($args{fromdate} eq $args{todate}) {
	$my_graph->set(title => "Rainfall Data for $args{fromdate}");
}

$my_graph->set_values_font("$font",12);
$my_graph->set_x_axis_font("$font",10);
$my_graph->set_y_axis_font("$font",10);
$my_graph->set_x_label_font("$font",12);
$my_graph->set_y_label_font("$font",12);
$my_graph->set_title_font("$font",14);

$my_graph->set_legend_font("$font",10);
$my_graph->set_legend(("$args{type} $moretitle rainfall","Historical Average",));

my $gd = $my_graph->plot([$Time, $RT, \@precip]);
open(IMG, '>'.$args{prefix}.'_Rain.png') or die $!;
binmode IMG;
print IMG $gd->png;
close IMG;

