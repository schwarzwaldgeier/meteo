package Weather::ReadPack;
use strict;

use Date::Calc qw(
             Date_to_Days
             Delta_Days
             Add_Delta_Days
			 Add_Delta_DHMS
         );
use Time::Local;

### to do
#		document

##########################################################
## Construct the object                                 ##
##########################################################

sub new {
	my $proto = shift;
	my $class = ref($proto) || $proto; # use as object or class
	my $self = {};
	my $begdate = shift; # of form mm/dd/yyyy
	my $enddate = shift;
	my $items = shift;
	my $inc = shift; # minutes/hourly/daily/weekly/monthly : output increment

	$self -> {DATA} = {}; # basic data array {DATA}{alias} = [values...]
	$self -> {BEGDATE} = $begdate;
	$self -> {ENDDATE} = $enddate;
	$self->{INC} = $inc;

	# adjust begin date so that intervals will be equal.

	my ($m,$d,$y) = split('/',$begdate);
	my ($m2,$d2,$y2) = split('/',$enddate);
	my $deltadays = Delta_Days($y, $m, $d, $y2, $m2, $d2);
	if ($inc eq 'weekly' && $deltadays%7>0) {
		($y, $m, $d ) = Add_Delta_Days($y, $m, $d, 7-$deltadays%7);
		$self -> {BEGDATE} = sprintf("%d/%d/%4d",$m,$d,$y);
	}

	$self -> {BEGSEC} = timelocal(0,0,0,$d,$m-1,$y-1900);

	$self -> {ERROR} = 0;
	$self -> {ERR_MSG} = [];
	#	initialize error messages

	@{$self -> {ERR_MSG}} = ( "",
						   "File open error",
						   "Unknown filter type",
						 );
	
	bless ($self, $class);

	readfiles($self, $items);

	return $self;

}

##########################################################
## Read in the archive                                  ##
##########################################################

sub readfiles {

	my $self = shift;
	my $items = shift;
	my $begdate = $self->{BEGDATE};
	my $enddate = $self->{ENDDATE};

	my @items = qw/Time TO  TI  HO  HI  DO  DI  WC Heat BR gust_dir gust_speed avg_dir avg_speed/;
	my %items;
	for (my $i=0;$i<=$#items;$i++) { $items{$items[$i]} = $i; } # column #

	#	build arrays for reading items

	my $rain=0; my $i=0;
	foreach (@{$items}) {
		if ($_ eq 'rainfall') { 
			$rain=1;
			splice(@{$items},$i,1);
			last;
		}
		$i++;
	}
	$i=0;
	foreach (@{$items}) {
		if ($_ eq 'extrema') { 
			splice(@{$items},$i,1);
			last;
		}
		$i++;
	}

	#	open and read each file in turn

	my ($month1,$day1,$year1) = split('/',$begdate);
	my ($month2,$day2,$year2) = split('/',$enddate);
	my $Dd = Delta_Days($year1,$month1,$day1,
						  $year2,$month2,$day2);
	my ($y,$m,$d);
	for ($i=0;$i<=$Dd;$i++) {
		($y,$m,$d) = Add_Delta_Days($year1,$month1,$day1,$i);
		my $day = timelocal(0,0,0,$d,$m-1,$y-1900);
		my $file = sprintf("pack_%d-%d-%d",$m,$d,$y);
		my $recs=0;
		my $afterrain=0;
		my $extrema=0;
		my @rain=();
		my $time;
		open (IN,"<$file") || die "Can't open $file $!\n";
		while (<IN>) {
			chomp;
			s/^\s*//;
			if (/other data/) {$afterrain=1;}
			if (/extrema data/) {$extrema=1;}
			next if /##/;
			if (!$afterrain && $rain && !$extrema) { # capture rain
				my @split = split(/\s+/,$_);
				push @rain,\@split;
			}
			if (!$afterrain && $extrema) { # capture extrema
				if (/Gust/){
					push @{$self->{DATA}{'extrema'}}, [ $y, $m, $d, (split(/\s+/,$_))[0,2,4,6,] ];
				}
				else {
					push @{$self->{DATA}{'extrema'}}, [ $y, $m, $d, (split(/\s+/,$_))[0,2,4,6,8] ];
				}
			}
			if ($afterrain) { # capture everything else
				my @line = split(/\s+/,$_);
				foreach my $item (@$items) {
					push @{$self->{DATA}{$item}},$line[$items{$item}];
				}
				#	fill in rain array with zeros where needed
				if (!defined $rain[0]) {push @{$self->{DATA}{'rainfall'}}, 0;}
				elsif ($rain[0]->[0] eq $line[0]) {
					push @{$self->{DATA}{'rainfall'}}, $rain[0]->[1];
					shift @rain;
				}
				else {push @{$self->{DATA}{'rainfall'}}, 0;}
				$recs++;
			}
		}
		close IN;
	}


	#	collapse arrays via increment
	my $inc = 0;
	if ($self->{INC} eq 'monthly') {
		########## doesn't work yet...
	}
	elsif ($self->{INC} eq 'weekly') {
		$inc = 7*24*6;
	}
	elsif ($self->{INC} eq 'daily') {
		$inc = 24*6;
	}
	elsif ($self->{INC} eq 'hourly') {
		$inc = 6;
	}
	else {return;}
	push @$items, 'rainfall';
	foreach my $item (@$items) { # avg each item
		next if $item eq "Time";
		my @output = ();
		my $sum = 0; my $n=0; my $i=1;
		$n=1 if $item eq 'rainfall';
		foreach (@{$self->{DATA}{$item}}) {
			if ($_ > -999) {
				$sum += $_;
				$n++ unless $item eq 'rainfall';
			}
			if ($i%$inc == 0) {
				$sum = $n ? $sum/$n : -999;
				push @output, $sum;
				$n = 0; $sum = 0;
				$n=1 if $item eq 'rainfall';
			}
			$i++;
		}
		if ($n>0) {push @output, $n ? $sum/$n : -999;}
		$self->{DATA}{$item} = \@output;
	}

	#	build time array

	my @output = ();
	if ($self->{INC} eq 'monthly') {
		########## doesn't work yet...
	}
	elsif ($self->{INC} eq 'weekly') {
		foreach (my $day=3; $day < $Dd+3; $day+=7) {
			($y,$m,$d) = Add_Delta_Days($year1,$month1,$day1,$day);
			push @output, sprintf("%02d/%02d/%4d",$m,$d,$y);
		}
	}
	elsif ($self->{INC} eq 'daily') {
		foreach (my $day=0; $day < $Dd; $day++) {
			($y,$m,$d) = Add_Delta_Days($year1,$month1,$day1,$day);
			push @output, sprintf("%02d/%02d",$m,$d);
		}
	}
	elsif ($self->{INC} eq 'hourly') {
		foreach (my $day=0; $day <= $Dd; $day++) {
			if ($Dd>1) {
				my ($mm,$dd) = (Add_Delta_Days($year1,$month1,$day1,$day))[1..2];
				push @output, map {sprintf("%2d/%02d %02d:00",$mm,$dd,$_)} (0..23);
			}
			else {
				push @output, map {sprintf("%02d:00",$_)} (0..23);
			}
		}
	}
	$self->{DATA}{'Time'} = \@output ;

	return;
}

##########################################################
## Retrieve an array of data                            ##
##########################################################

sub get {

	my $self = shift;
	my $alias = shift;
	my $nodata = shift;

	my @data;
	foreach (@{$self->{DATA}{$alias}}) {
		next if ($nodata && $_ <= -999);
		push @data,$_;
	}
	return \@data;
}

##########################################################
## Retrieve an array of data with yyyy-mm-ddThh:mm:ss   ##
##########################################################

sub getdate {

	my $self = shift;
	my $alias = shift;
	my $nodata = shift;

	my @data;
	my ($month,$day,$year) = split('/',$self->{BEGDATE});
	my $min = 10;

	if ($alias ne 'extrema' && $alias ne 'rainfall') {
		foreach (@{$self->{DATA}{$alias}}) {
			next if ($nodata && $_ <= -999);
			my ($y,$mn,$d,$h,$m,$s) = Add_Delta_DHMS($year,$month,$day,0,0,0,
													 0,0,$min,0);
			my $dat = $y . "-" . $mn . "-" . $d . "T" . $h . ":" . $m . ":" . $s;
			push @data,[$dat,$_];
			$min += 10;
		}
	}
	else {
		
	}

	return \@data;
}

##########################################################
## Retrieve an array of data with perl time in seconds  ##
##########################################################

sub getsec {

	my $self = shift;
	my $alias = shift;
	my $nodata = shift;

	my @data;
	my $time = $self->{BEGSEC}-600;
	foreach (@{$self->{DATA}{$alias}}) {
		$time += 600;
		next if ($nodata && $_ <= -999);
		push @data,[$time,$_];
	}

	return \@data;
}

##########################################################
## Multiplex data                                       ##
##########################################################

sub multiplex {

	my $self = shift;
	my @aliases = @_;

	# find start and end times
	my $max = 0;
	my $min = time;

	foreach (@aliases) {
		$min = $self->{DATA}{$_}[0]->[0] < $min ? $self->{DATA}{$_}[0]->[0] : $min;
		$max = $self->{DATA}{$_}[-1]->[0] > $max ? $self->{DATA}{$_}[-1]->[0] : $max;
	}
	print "######## $min , $max\n";

	#	create array of times that occur, and where they occur.
	my %mult;
	#my $mask = 0x01;
	for (my $i=0;$i<=$#aliases;$i++) {
		my $alias = $aliases[$i];
		foreach my $time (@{$self->{DATA}{$alias}}) {
			if (!defined $mult{$time->[0]}) {$mult{$time->[0]} = "";}
			vec($mult{$time->[0]},$i,1) = 1;
		}
		#$mask <<= $mask;
	}

	# initialize output array
	
	#my @null = map {undef;} @aliases;
	my @null = map {0;} @aliases;
	my @output;
	my @ptr = map {0;} @aliases; # pointers into data
	my $output = 0; # output flag - when do I have a full set of data?
	my $i=0;

	foreach my $t (sort {$a <=> $b} keys %mult) {
		$output[$i] = [$t,@null];
		my $mask = 0x01;
		print "---------------------\n";
		for (my $j=0; $j<=$#aliases;$j++) {
			#if ($mult{$t} & $mask) {
			if (vec($mult{$t},$j,1)) {
				$output[$i][$j] = $self->{DATA}{$aliases[$j]}[$ptr[$j]]->[$j];
				print STDERR "-->$j, $mult{$t}, $output[$i][$j]\n";
			}
			$ptr[$j]++;
			$mask <<= $mask;
		}
		$i++;
	}

	return \@output;
}

1;
