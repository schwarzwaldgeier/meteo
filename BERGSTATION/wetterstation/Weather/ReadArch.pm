package Weather::ReadArch;
use strict;

### to do
#		document

##########################################################
## Construct the object                                 ##
##########################################################

sub new {
	my $proto = shift;
	my $class = ref($proto) || $proto; # use as object or class
	my $self = {};
	my $archive = shift;

	$self -> {ARCH} = $archive;
	$archive =~ s/[^\/]+$//;
	$self -> {ADIR} = $archive; # archive directory path

	$self -> {DATA} = {}; # basic data array {DATA}{alias} = [values...]

	$self -> {FILTER} = {}; # which filter type for each alias

	%{$self -> {TYPES}} = ( 'RLE' => 1,
						 'LINEAR' => 1,
						 'MEAN' => 1,
						 'RMS' => 1,
						 'MEDIAN' => 1,
	                    );
	
	$self -> {ERROR} = 0;
	$self -> {ERR_MSG} = [];
	#	initialize error messages

	@{$self -> {ERR_MSG}} = ( "",
						   "File open error",
						   "Unknown filter type",
						 );

	bless ($self, $class);
	return $self;

}

##########################################################
## Read in the archive                                  ##
##########################################################

sub read {

	my $self = shift;

	open (IN,"<$self->{ARCH}") || die "Can't open archive $self->{ARCH}, $!\n";

	while (<IN>) {
		chomp;
		my ($alias, $time, $value) = split(' : ',$_);
		$self->{ALIAS}{$alias}++;
		push @{$self->{DATA}{$alias}}, [$time, $value];
	}
	return;
}

##########################################################
## Get a list if aliases                                ##
##########################################################

sub aliases {
	my $self = shift;
	return keys %{$self->{ALIAS}};
}

##########################################################
## Retrieve an array of data with yyyy-mm-ddThh:mm:ss   ##
##########################################################

sub get {

	my $self = shift;
	my $alias = shift;

	my @data;
	foreach (@{$self->{DATA}{$alias}}) {
		my @t = localtime($_->[0]);
		my $dat = ($t[5]+1900) . "-" . ($t[4]+1) . "-" . $t[3] . "T" . $t[2] . ":" . $t[1] . ":" . $t[0];
		push @data,[$dat,$_->[1]];
	}

	return \@data;
}

##########################################################
## Retrieve an array of data with perl time in seconds  ##
##########################################################

sub getsec {

	my $self = shift;
	my $alias = shift;

	my @data;
	foreach (@{$self->{DATA}{$alias}}) {
		push @data,[$_->[0],$_->[1]];
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

##########################################################
## Set the type of filter to use                        ##
##########################################################

sub filter {

	my $self = shift;
	my ($alias, $type) = @_;

	if (! defined $self->{TYPES}{$type}) {
		$self->{ERROR} += 2;
		return $self->{ERROR};
	}

	$self->{FILTER}{$alias} = $type;

	return;
}

1;
