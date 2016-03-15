package Weather::Math;
$VERSION = 1.00;
use strict;

use constant PI => 4*atan2(1,1);
use constant PI180 => 4*atan2(1,1)/180;
 
use Class::MethodMaker
	new_with_init	=> 'new',
	new_hash_init	=> '_init_args',
	static_hash	=> 'counter',
	get_set	=> [qw( wavg avg max min timedef deltas nodata start_stop window )];

sub count	{ $_[0]->counter('count') }
sub _incr_count	{ $_[0]->counter_tally('count') }
sub _decr_count	{ $_[0]->counter(count=>$_[0]->counter('count')-1) }

sub init
{
	my ($self, %args) = @_;
	$self->_init_args(%args);
	$self->_incr_count();
	$self->{_raw}= [];
	return $self;
}

# destructor adjusts object count
sub DESTROY { $_[0]->_decr_count() }

# load an object from an array of [time,val]
# do a deep copy
sub load
{
	my ($self, $input) = @_;
	my $ERROR = 0;
	foreach (@{$input}) {
		push @{$self->{_raw}},[$_->[0], $_->[1]];
	}
	return $ERROR;
}

# dump an object to a file image
# do a deep copy
sub dump
{
	my $self = shift;
	my @output;
	foreach (@{$self->{_raw}}) {
		push @output,[$_->[0], $_->[1]];
	}
	return \@output;
}

#	given min/max bounds, set all values at or beyond
#	those bounds to undef
#	if the delta between 2 adjacent values is greater than the given
#	limit, then replace spike with previous value.
sub setbounds {
	my $self = shift;
	my $lbd = shift;
	my $ubd = shift;
	my $nodata = $self->nodata; # value that represents no data
	my $ERROR = 0;
	if (!defined $lbd) {return "bound value not defined"; die;}
	my @output;
	foreach (@{$self->{_raw}}){
		if ($_->[1] <= $lbd || $_->[1] >= $ubd) {
			$_->[1] = $nodata;
		}
		push @output, $_;
	}
	@{$self->{_raw}} = @output;
	return $ERROR;
}

#	Despike an array
#	if the delta between 2 adjacent values is greater than the given
#	limit, then delete spike 
sub despike {
	my $self = shift;
	my $spike = shift;
	my $nodata = $self->nodata; # value that represents no data
	my $ERROR = 0;
	if (!defined $spike) {return "Spike value not defined"; die;}
	my @output;
	my $last;
	foreach (@{$self->{_raw}}){
		if (!defined $last) {
			$last = $_->[1];
			$last = undef if $_->[1] == $nodata;
			push @output, $_;
		}
		else {
			next if abs($_->[1] - $last) >= $spike;
			$last = $_->[1];
			push @output, $_;
		}
	}
	@{$self->{_raw}} = @output;
	return $ERROR;
}

#	Force an array to be monotonic
sub monotonic {
	my $self = shift;
	my $ERROR = 0;
	my @output;
	my $last;
	my $add = 0;
	foreach (@{$self->{_raw}}){
		if (!defined $last) {
			$last = $_->[1];
			push @output, $_;
		}
		else {
			if (($_->[1] - $last + $add) < 0) {
				$add = $last;
			}
			$last = $_->[1] + $add;
			$_->[1] += $add;
			push @output, $_;
		}
	}
	$self->{_raw} = \@output;
	return $ERROR;
}

sub prt_time {
    my $time = shift;
    my @t = localtime($time);
    my $dat = ($t[5]+1900) . "-" . ($t[4]+1) . "-" . $t[3] . " " . $t[2] . ":" . $t[1] . ":" .
$t[0];
    return $dat;
}

#	Harmonize
#	Take two arrays and infill so both have values at all common times.
sub harmonize {
	my $self = shift; # this will be the output object
	my $arr1 = shift; # input one
	my $arr2 = shift; # input two
	my $start_stop = $self->start_stop; # input or midnight
	my $nodata = $self->nodata; # value that represents no data
	my $window = $self->window;
	my $ERROR = 0;
	
	#------ First determine the start and end times for output

	my ($begt, $endt, $enddata) = 
	                timerange($arr1->{_raw}->[0][0], 
					          $arr1->{_raw}->[-1][0], 
							  'input', $window);
	my ($begt2, $endt2, $enddata2) = 
	                timerange($arr2->{_raw}->[0][0], 
					          $arr2->{_raw}->[-1][0], 
							  'input', $window);
	if ($begt2 < $begt) {$begt = $begt2;}
	if ($endt2 > $endt) {$endt = $endt2;}
	if ($enddata2 > $enddata) {$enddata = $enddata2;}
	$self->timedef([$begt, $endt, ($endt-$begt)/$window, $window, $enddata]);
	
	#------ Now walk the arrays adding elements where necessary

	my (@outT, @out1, @out2); # output time, value1, value2
	my ($i1, $i2) = (0,0); # pointers into two input arrays
	my ($last1, $last2) = ($nodata, $nodata); # last values from each input

	#   initialize pointers to just past tbeg

	for ($i1=0; $i1<=$#{$arr1->{_raw}};$i1++) {
		last if $arr1->{_raw}->[$i1][0] > $begt;
		$last1 = $arr1->{_raw}->[$i1][1];
	}
	for ($i2=0; $i2<=$#{$arr2->{_raw}};$i2++) {
		last if $arr2->{_raw}->[$i2][0] > $begt;
		$last2 = $arr2->{_raw}->[$i2][1];
	}

	#	walk the arrays

	while () {
		last if (($i1 > $#{$arr1->{_raw}}) && 
		         ($i2 > $#{$arr2->{_raw}})) ;
		if ( $i2 > $#{$arr2->{_raw}} || 
		        $arr1->{_raw}->[$i1][0] < $arr2->{_raw}->[$i2][0]) {
			push @outT, $arr1->{_raw}->[$i1][0];
			push @out1, $arr1->{_raw}->[$i1][1];
			push @out2, $last2;
			$last1 = $arr1->{_raw}->[$i1][1];
			$i1++; 
		}
		elsif ( $i1 > $#{$arr1->{_raw}} || 
		        $arr1->{_raw}->[$i1][0] > $arr2->{_raw}->[$i2][0]) {
			push @outT, $arr2->{_raw}->[$i2][0];
			push @out2, $arr2->{_raw}->[$i2][1];
			push @out1, $last1;
			$last2 = $arr2->{_raw}->[$i2][1];
			$i2++; 
		}
		elsif ($arr1->{_raw}->[$i1][0] == $arr2->{_raw}->[$i2][0]) {
			push @outT, $arr1->{_raw}->[$i1][0];
			push @out1, $arr1->{_raw}->[$i1][1];
			push @out2, $arr2->{_raw}->[$i2][1];
			$last1 = $arr1->{_raw}->[$i1][1];
			$last2 = $arr2->{_raw}->[$i2][1];
			$i1++; $i2++;
		}
	}
	for (my $i=0; $i<= $#outT; $i++) {
		$self->{_raw}->[$i] = [$outT[$i], [$out1[$i], $out2[$i]]];
	}
	return $ERROR;
}

#	resample an array to an even interval, modulo midnight
#   input assumed to be array of value changes
#   create min, max, and avg in each sample window.
#	Parameters are window length in seconds, and start-end flag -
#   do we start the output on midnight boundaries or with the input range?
#	what value do we use to represent no data?
#	values before midnight on the front end, and after midnight on the back
#	end will be truncated if we use midnight boundaries.
#	input type is the type of measurement, either point (Temperature) or
#	cumulative (rainfall total).
#	Note that we are generating interval quantities, so we will post the
#	derived values in the centers of the windows. That is, if we use a
#	10 minute widow, starting at midnight, the first value will be
#	posted at 00:05, and represent the interval from 24:00 to 00:10.
#	Intervals will be set up as begin <= time < end.
sub sample {
	my $self = shift;
	my $start_stop = $self->start_stop; # input or midnight
	my $nodata = $self->nodata; # value that represents no data
	my $ERROR = 0;
	my @max;
	my @min;
	my @avg;
	my @wavg;
	my @t; 
	#------ Repair daylight savings errors
	my $add = 0;
	my $last = 0;
	foreach (@{$self->{_raw}}) {
		$add = 3600 if $_->[0] < $last;
		$last = $_->[0];
		$_->[0] += $add;
	}
	
	#------ First determine the start and end times for output

	my ($begt, $endt, $numout, $window, $enddata ) ;
	##my ($begt, $endt, $numout, $window, $enddata ) = @{$self->timedef()};
	$window = $self->window;
	my $numvals = $#{$self->{_raw}};
	($begt, $endt, $enddata) = 
	                timerange($self->{_raw}->[0][0], 
					          $self->{_raw}->[-1][0], 
							  $start_stop, $window);

	#------ Now resample
	
	my $n=0;
	my $currt = $self->{_raw}[0]->[0];
	my $currv = $self->{_raw}[0]->[1];
	my $zero = 0;
	if (ref $currv eq "ARRAY") {$nodata = [$nodata, 0]; $zero=[0,0];}
	#	if truncating front of array, find first needed datapoint
	if ($currt < $begt) {
		for ($n=0; $n< $#{$self->{_raw}}; $n++) {
			last if $self->{_raw}[$n]->[0] >= $begt;
		}
		$currt = $self->{_raw}[$n]->[0];
		$currv = $self->{_raw}[$n]->[1];
	}
	#	Now work into data
	$last = $nodata;
	for (my $t=$begt; $t<=$endt; $t+=$window) {
		if (($t+$window) < $currt) { # no data in current window
			push @t, $t+$window/2;
			push @avg, $last; push @wavg, $last;
			push @min, $last; push @max, $last;
		}
		elsif ($n >= $numvals ) { # past end of input data
			push @t, $t+$window/2;
			push @avg, $nodata; push @wavg, $nodata;
			push @min, $nodata; push @max, $nodata;
		}
		else {
			my $min = $currv;
			my $max = $currv;
			my $sum = $currv;
			$last = $currv;
			my $wsum = wsum($zero, $currv, ($currt - $t)/$window, $nodata);
			my $lastt = $currt;
			$n++;
			$currt = $self->{_raw}[$n]->[0];
			$currv = $self->{_raw}[$n]->[1];
			my $num = 1;
			while ($currt < ($t+$window) && $n < $numvals) {
				$sum = &sum($sum, $currv, $nodata);
				$wsum = &wsum($wsum, $currv, ($currt - $lastt)/$window, $nodata);
				##$wsum = &wsum($wsum, $last, ($currt - $lastt)/$window, $nodata);
				$min = &vmin($min, $currv, $nodata);
				$max = &vmax($max, $currv, $nodata);
				$lastt = $currt;
				$last = $currv;
				$num++;
				$n++;
				$currt = $self->{_raw}[$n]->[0];
				$currv = $self->{_raw}[$n]->[1];
			}
			if (ref $nodata ne "ARRAY") {
				push @avg, $sum/$num;
			}
			else {
				push @avg, [$sum->[0]/$num,$sum->[1]];
			}
			push @wavg, &wsum($wsum, $currv, ($t + $window - $lastt)/$window, $nodata);
			push @max, $max; push @min, $min;
			push @t, $t+$window/2;
		}
	}
	$self->avg(\@avg); $self->wavg(\@wavg);
	$self->max(\@max); $self->min(\@min);
	$self->timedef([$t[0], $t[-1], $#t, $window,]);

	return $ERROR;
}

########### routines for vectore and scalars
# Vectors are [magnitude, angle] with angle in degrees.

#	add two scalars or two vectors.
sub sum {
	my $sum = shift;
	my $add = shift;
	my $nodata = shift;
	if (ref $add ne "ARRAY") {
		return $sum if $add == $nodata;
		return $add if $sum == $nodata;
		return $add + $sum;
	}
	else {
		return $sum if $add->[0] == $nodata->[0];
		return $add if $sum->[0] == $nodata->[0];
		my $x = $sum->[0]*sin($sum->[1]*PI180) + $add->[0]*sin($add->[1]*PI180);
		my $y = $sum->[0]*cos($sum->[1]*PI180) + $add->[0]*cos($add->[1]*PI180);
		my $ang = (atan2($x,$y))*180/PI;
		my $mag = sqrt($x**2 + $y**2);
		$ang = int($ang+.5)%360; # wrap angle to 0-360
		return [$mag, $ang];
	}
}

#	add two scalars or two vectors, with a weighting factor
sub wsum {
	my $sum = shift;
	my $add = shift;
	my $wt = shift;
	my $nodata = shift;
	if (ref $add ne "ARRAY") {
		return $sum if $add == $nodata;
		return $add if $sum == $nodata;
		return $add*$wt + $sum;
	}
	else {
		return $sum if $add->[0] == $nodata->[0];
		return $add if $sum->[0] == $nodata->[0];
		my $x = $sum->[0]*sin($sum->[1]*PI180) + $wt*$add->[0]*sin($add->[1]*PI180);
		my $y = $sum->[0]*cos($sum->[1]*PI180) + $wt*$add->[0]*cos($add->[1]*PI180);
		my $ang = (atan2($x,$y))*180/PI;
		my $mag = sqrt($x**2 + $y**2);
		$ang = int($ang+.5)%360; # wrap angle to 0-360
		if ($mag < 0.00001) {$ang = $add->[1];}
		return [$mag, $ang];
	}
}

#	Find the minimum of two scalars or vectors
sub vmin {
	my $one = shift;
	my $two = shift;
	if (ref $two ne "ARRAY") {
		return $one if $one < $two;
		return $two;
	}
	else {
		return $one if $one->[0] < $two->[0];
		return $two;
	}
}

#	Find the maximum of two scalars or vectors
sub vmax {
	my $one = shift;
	my $two = shift;
	if (ref $two ne "ARRAY") {
		return $one if $one > $two;
		return $two;
	}
	else {
		return $one if $one->[0] > $two->[0];
		return $two;
	}
}

#	Derivative - take a derivative of an array - store only changes
sub derivative {
	my $self = shift;
	my $arr = shift;
	my $nodata = $self->nodata; # value that represents no data
	my $ERROR = 0;
	my @output;
	my ($begt, $endt, $numt, $deltat) = @{$self->timedef()};
	my $last = $self->$arr()->[0];
	for (my $i=1;$i<=$numt;$i++) {
		if ($last == $nodata) {$last = $self->$arr()->[$i];}
		if ($last != $self->$arr()->[$i] && $self->$arr()->[$i] != $nodata ) {
			push @output, [$begt + $i*$deltat, $self->$arr()->[$i] - $last];
			$last = $self->$arr()->[$i];
		}
	}
	$self->deltas(\@output);
	return $ERROR;
}

#	stats - return overall raw array statistics : return [time, value]
sub stats {
	my $self = shift;
	my $stat = shift; # min, max, avg, sum
	my $nodata = $self->nodata; # value that represents no data
	my $ERROR = 0;


	my ($time, $value) ;
	#my ($time, $value) = ($self->{_raw}->[0][0],$self->{_raw}->[0][1]);
	my $num=0;
	if (ref $self->{_raw}->[0][1] ne "ARRAY") {
		foreach (@{$self->{_raw}}){
			next if $_ == $nodata;
			if (!defined $value) {$value = $_->[1]; $time = $_->[0];}
			$num++;
			if (($stat eq 'max') && ($value < $_->[1])) {
				$value = $_->[1];
				$time = $_->[0];
			}
			elsif (($stat eq 'min') && ($value > $_->[1])) {
				$value = $_->[1];
				$time = $_->[0];
			}
			elsif ($stat eq 'sum' || $stat eq 'avg') {
				$value += $_->[1];
			}
		}
		if ($stat eq 'avg') {$value /= $num;}
	}
	else {
		foreach (@{$self->{_raw}}){
			next if $_->[1]->[0] == $nodata; 
			if (!defined $value) {$value = $_->[1]; $time =$_->[0]; }
			$num++;
			if (($stat eq 'max') && ($value->[0] < $_->[1]->[0])) {
				$value = $_->[1];
				$time = $_->[0];
			}
			elsif (($stat eq 'min') && ($value->[0] > $_->[1]->[0])) {
				$value = $_->[1];
				$time = $_->[0];
			}
			elsif ($stat eq 'sum' || $stat eq 'avg') {
				$value = sum($value, $_);
			}
		}
		if ($stat eq 'avg') {$value->[0] /= $num;}
	}

	return [$time, $value];
}

#	round off beginning and ending times to a modulo midnight number
#	so that a window will be centered at midnight. Either start the
#	times at midnight, or at the actual input data.
sub timerange {
	my $aday = 24*60*60;
	my $firstT = shift;
	my $lastT = shift;
	my $start_stop = shift;
	my $window = shift;
	my ($sec,$min,$hr) = (localtime($firstT))[0..2];
	my $midnight = $firstT - $sec - 60*$min - 3600*$hr;
	my $begt = int(($firstT - $midnight)/$window)*$window + $midnight;
	my $endt = int(($lastT - $midnight)/$window)*$window + $midnight;
	my $enddata = $endt;
	if ($start_stop eq 'midnight') {
		#	if len < 48 hr, truncate to one day and fill it
		if (($endt-$begt)< 2*$aday) {
			my $midt = ($endt+$begt)/2; # center time
			($sec,$min,$hr) = (localtime($midt))[0..2];
			$begt = $midt - $sec - 60*$min - 3600*$hr;
			$endt = $begt + $aday - $window;
		}
		#	len > 2 days, truncate to nearest boundaries
		else {
			if (($begt - $midnight) < $aday/2) {
				$begt = $midnight;
			}
			else {$begt = $midnight + $aday;}
			$endt = int(($endt-$begt+$aday/2)/($aday))*$aday + $begt;
		}
	}
	return ($begt, $endt, $enddata);
}

##########################################################
## Calculate Wind Chill                                 ##
##########################################################

#	T in Farenheit, Speed in mph

sub windchill {
	my $windspeed = shift;
	my $temperature = shift;
	my $nodata = shift;
	if ($windspeed < 0 || $temperature < -200) {return $nodata;}
	if ($temperature > 100) {return $temperature;}
	#	old formula
	my $wc =  0.0817*(3.71*$windspeed**0.5 + 5.81 - 0.25*$windspeed)*
			 ($temperature - 91.4) + 91.4;
	#	new formula
	my $wcnew = 35.74 + 0.6215*$temperature - 35.75*($windspeed**0.36) +
	            0.4275*$temperature*($windspeed**0.16);
	if ($wc > $temperature) {$wc = $temperature;}
	if ($wcnew > $temperature) {$wcnew = $temperature;}
	if ($windspeed < .1) {$wc = $temperature;}
	if ($windspeed < .1) {$wcnew = $temperature;}
	return sprintf("%5.1f",$wcnew), sprintf("%5.1f",$wc);
}

##########################################################
## Calculate Heat Index                                 ##
##########################################################

#	T in Farenheit, humidity in percent

sub heatindex {
	my $hum = shift;
	my $temp = shift;
	my $nodata = shift;
	my $heat;
	if ($hum < 0 || $temp < -200) {return $nodata;}
	if ($temp < 78) {return $temp;}
	$heat =  -42.379 + 2.04901523*$temp + 10.14333127*$hum 
	          - 0.22475541*$temp*$hum - 6.83783e-03*$temp**2 
			  - 5.481717e-02*$hum**2 + 1.22874e-03*$temp**2*$hum 
			  + 8.5282e-04*$temp*$hum**2 - 1.99e-06*$temp**2*$hum**2;
	
	if ($heat < $temp) {$heat = $temp;}
	return $heat;
}


##########################################################
## Maximum and where it occurred                        ##
##########################################################

sub imax {
    my $max = shift(@_);
    my $foo;
	my $idx = 0;
    my $i=0;
    foreach $foo (@_) {
		$i++;
		next if !defined $foo;
        if (!defined $max || $max < $foo) {
			$max = $foo ;
			$idx = $i;
		}
    }
    return [$max, $idx];
}

##########################################################
## Minimum and where it occurred                        ##
##########################################################

sub imin {
    my $min = shift(@_);
    my $foo;
	my $idx = 0;
    my $i=0;
    foreach $foo (@_) {
		$i++;
		next if !defined $foo;
        if (!defined $min || $min > $foo) {
			$min = $foo ;
			$idx = $i;
		}
    }
    return [$min, $idx];
}   #   end min

##########################################################
## Median                                               ##
##########################################################

#	From _Mastering Algoritms With Perl_ page 602-603
sub odd_median {
	my $arrayref = shift;
	my @array = sort @$arrayref;
	return $array[(@array - (0,0,1,0)[@array & 3])/2];
}

##########################################################
## Convert degrees into a compass direction             ##
##########################################################

sub compass {
	my $degrees = shift;
	my @dir = qw / N NNE NE ENE E ESE SE SSE S SSW SW WSW W WNW NW NNW / ;
	return $dir[int(($degrees+11.25)/22.5)%16];
}


1;

__END__

=head1 NAME

Weather_alpha::Math - Miscellaneous weather-related math functions

=head1 VERSION

Version 1.00, May 4, 2001.

=head1 SYNOPSIS

	use Weather_alpha::Math;

	my $RdAr = Weather::ReadArch->new("$path"."/"."$archive");

	$RdAr -> read;

	#---------------------------------------------------
	#------------ do rainfall
	#---------------------------------------------------

	my $RT = $RdAr -> getsec('RT');

	my $rain = Weather_alpha::Math->new;
	my $error = $rain->load($RT);
	if ($error) {die "Rain loading error, $error\n";}
	$error = $rain->despike(5); # 5 inch rainfall spikes are skipped
	if ($error) {die "Rain despking error, $error\n";}
	$error = $rain->monotonic;
	if ($error) {die "Rain monotonic error, $error\n";}
	$error = $rain->sample(10*600);
	if ($error) {die "Rain sampling error, $error\n";}

=head1 DESCRIPTION

=head2 Overview


=head2 Constructor and initialization


=head2 Class and object methods

=over 4

=item load :

=item dump :

=item count :

=item DESTROY :

=item get/set :

=item clear :

=item fields :

=back

=head1 DIAGNOSTICS

=over 4

=item load : Unknown field name, xxxxxx

=back

=head1 BUGS

None known

=head1 FILES

Requires Class::MethodMaker which may be gotten from www.cpan.org

=head1 AUTHOR

Alan Jackson - alan@ajackson.org

