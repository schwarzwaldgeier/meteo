package Weather::Archive;
use strict;

### to do
#		need an error message subroutine
#		improve logging (log rotates, rotate logs?, 
#		check diskspace and raise a flag
#		document
#		deal with daylight savings.....

##########################################################
## Construct the object                                 ##
##########################################################

sub new {
	my $proto = shift;
	my $class = ref($proto) || $proto; # use as object or class
	my $self = {};
	my $logfile = shift;
	my $archive = shift;

	$self -> {LOG} = $logfile;
	$self -> {ARCH} = $archive;
	$archive =~ s/[^\/]+$//;
	$self -> {ADIR} = $archive; # archive directory path

	open (LOG,">>$logfile") || die "Can't open logfile, $logfile, $!\n";
	print LOG "#--------------- start ",time," --------------------\n";

	$self -> {DATA} = {}; # basic data array {DATA}{alias} = [values...]

	$self -> {MAXREC} = 10; # Max number of records to buffer before write
	$self -> {MAXTIME} = 30; # Max minutes between writing buffers
	$self -> {LASTWRITE} = {}; # time of last write (for each alias)
	$self -> {'ROT-NEXT'} = ''; # time of next file rotation, set in rotate_when
	rotate_when($self, 10); # Rotate archive 10 minutes after midnight

	$self -> {ERROR} = 0;
	$self -> {ERR_MSG} = [];
	#	initialize error messages

	@{$self -> {ERR_MSG}} = ( "",
						   "File open error",
						 );

	bless ($self, $class);
	return $self;

}

##########################################################
## Set the max time and max records between writes      ##
##########################################################

sub writewhen {

	my $self = shift;
	my ($time, $rec ) = @_;

	$self -> {MAXREC} = $rec; # Max number of records to buffer before write
	$self -> {MAXTIME} = $time; # Max minutes between writing buffers

	if ($time<1) {die "Time for writewhen < 1\n";}
	if ($rec<1) {die "Records for writewhen < 1\n";}

	return;
}

##########################################################
## Set the minutes after midnight to rotate the archive ##
##########################################################

sub rotate_when {

	my $self = shift;
	my $time = shift;

	$self -> {ROTATE} = $time; # Minutes after midnight to rotate archive
	my $now = time;
	my ($sec,$min,$hr,) = localtime($now);
	my $midnight = $now - $sec - 60*$min - 3600*$hr;
	if ($time < 0 || $time < ($now - $midnight)) {$midnight +=86400};
	$self->{'ROT-NEXT'} = $midnight + $time;

	if (abs($time) > 1440 ) {die "Time for rotate_when > 1440\n";}

	return;
}

##########################################################
## Add a new value                                      ##
##########################################################

sub add {

	my $self = shift;
	my ($value, $alias ) = @_;

	my $time = time;
	my $last = -99999;

	if (exists $self->{DATA}{$alias}) {
		$last = (split(' : ',${$self->{DATA}{$alias}}[-1]))[1]; # remove timestamp
	}
	else {
		$self->{LASTWRITE}{$alias} = $time;
		push @{$self->{DATA}{$alias}},sprintf("%d : %s",$time, $value);
		return;
	}
	if ($value eq $last && @{$self->{DATA}{$alias}}>1) {
		# replace last value
		pop @{$self->{DATA}{$alias}};
		push @{$self->{DATA}{$alias}},sprintf("%d : %s",$time, $value);
	}
	else { 
		# append new value
		push @{$self->{DATA}{$alias}},sprintf("%d : %s",$time, $value);
	}

	#	Is it time to rotate the archive?

	if ($time > $self->{'ROT-NEXT'}) {
		rotate($self);
		$self->{'ROT-NEXT'} += 86400;
	}
	
	#	Is it time to archive this one?

	if (@{$self->{DATA}{$alias}} >= $self->{MAXREC}) {
		archive($self, $alias);
		$self->{LASTWRITE}{$alias} = $time;
		print LOG "$time wrote $alias maxrec\n";
	}
	elsif ( defined $self->{LASTWRITE}{$alias} && ($time - $self->{LASTWRITE}{$alias}) > $self->{MAXTIME}*60) {
		archive($self, $alias);
		$self->{LASTWRITE}{$alias} = $time;
		print LOG "$time wrote $alias maxtime\n";
	}
	
	return ;
}

##########################################################
## Archive a buffer                                     ##
##########################################################

sub archive {

	my $self = shift;
	my $alias = shift;

	my $arch = $self->{ARCH};
	open (ARCH,">>$self->{ARCH}") || die "Can't open archive, $self->{ARCH}, $!\n";
	#open (LOG,">>$logfile") || die "Can't open logfile, $logfile, $!\n";

	my $last = pop @{$self->{DATA}{$alias}};
	foreach (@{$self->{DATA}{$alias}}) {
		print ARCH "$alias : $_\n";
	}
	close ARCH;

	#	flush buffer (replace array with last element)
	
	@{$self->{DATA}{$alias}} = ();
	push @{$self->{DATA}{$alias}}, $last;

	return;
}

##########################################################
## Rotate archive                                       ##
##########################################################

sub rotate {

	my $self = shift;
	my $time = time;
	print STDERR "--- flush buffers ---\n";

	#	flush all the buffers

	flush($self);

	#	rename the archive

	my $name = "arch" . $time;
	rename $self->{ARCH} , $self->{ADIR} . $name;
	`touch $self->{ARCH}`;

	return;
}

##########################################################
## Flush all the buffers                                ##
##########################################################

sub flush {

	my $self = shift;
	my $time = time;

	#	flush all the buffers

	open (ARCH,">>$self->{ARCH}") || die "Can't open archive, $self->{ARCH}, $!\n";
	my $alias;
	foreach $alias (keys %{$self->{DATA}}) {
		my $last = pop @{$self->{DATA}{$alias}};
		push @{$self->{DATA}{$alias}}, $last; # store last value twice
		foreach (@{$self->{DATA}{$alias}}) {
			print ARCH "$alias : $_\n";
		}
		@{$self->{DATA}{$alias}} = ();
		push @{$self->{DATA}{$alias}}, $last;
		$self->{LASTWRITE}{$alias} = $time;
	}
	close ARCH;

	print LOG "Flushed buffers\n";
	close LOG;
	open (LOG,">>$self->{LOG}") || die "Can't open logfile, $self->{LOG}, $!\n";

	return;
}


1;

=head1 NAME

Weather::Archive - create a RLE file from weather station serial input

=head1 VERSION

Version 1.0, August, 2000

=head1 SYNOPSIS

Create an archive file of raw weather data, basically using run-length 
encoding, in the sense that only when a value changes is it stored. For
example, if the input outside temperture values are

	10:30 58.2
	10:31 58.2
	10:32 58.3

then we will only store

	10:30 58.2
	10:32 58.3

Here is a sample of an archive file :

	WGS : 990853209 :   0.00
	WAS : 990853209 :   0.00
	WC : 990853209 :   75.2
	F1W : 990853209 : 0
	RR : 990853213 :   0.00
	RT : 990853072 :  20.98
	RY : 990853072 :   0.00
	F1R : 990853072 : 0
	F3R : 990853072 : 10
	RS : 990853072 : 00:00:01/01/99
	TO : 990853205 :   75.7
	TO : 990853390 :   75.7
	DO : 990853205 :   66.2
	DO : 990853984 :   66.2
	F1O : 990853205 : 1
	HO : 990853205 : 74
	HO : 990853245 : 74
	HO : 990853984 : 75

Fields are alias, time, value.

=head1 DESCRIPTION

	my $Wobj = Weather::Archive->new($logfile, $archive_directory);

Creates a new object, and tells it where to write log and archive records.

	$Wobj -> writewhen(15,25); # minutes , records

When should the buffer be flushed to disk? Based on both time and number of
records buffered up. This is just to keep the disk activity to a minimum.
These apply to each item separately - that is a separate buffer is kept
for say inside temperature separate from outside temperature.

	$Wobj -> rotate_when(10); # minutes from midnight

The archive file will be closed out, and a new one started around midnight.
This just gives everything a chance to finish collecting the data from 
yesterday. Positive numbers imply minutes after midnight.

	$Wobj -> flush;

Flush the buffer now.

	$Wobj->add($value,$alias);

=head1 BUGS

Doesn't deal well with daylight savings. Should probably recast it all into
GMT terms.

=head1 AUTHOR

Alan Jackson - weatherman@ajackson.org

=cut
