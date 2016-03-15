#!/usr/bin/perl -w

#	replace fields with nodata

#	usage Edit_packfiles.pl --field <TO/TI/HO/HI/DO/DI/WC/Heat/BR/gust_dir/gust_speed/avg_dir/avg_speed> 
#                           --fromtime <mm/dd/yyyyThh:mm>
#                           --totime <mm/dd/yyyyThh:mm>

BEGIN {push @INC, "/home/ajackson/bin/lib"}


use Carp;
use strict;

use Date::Calc qw(
             Date_to_Days
             Delta_Days
             Add_Delta_Days
			 Add_Delta_DHMS
         );


#--------------------------------------------------------------
#	Read in arguments
#--------------------------------------------------------------

my $VERSION = "1.0";

my %flds = ('TO'=>1, 'TI'=>2, 'HO'=>3,'HI'=>4,'DO'=>5,'DI'=>6,'WC'=>7,'Heat'=>8,
            'BR'=>9,'gust_dir'=>10,'gust_speed'=>11,'avg_dir'=>12,'avg_speed'=>13);

use  Getopt::Declare;

my $specification = q(  
[strict]
[pvtype: datetime	/\d{1,2}\/\d{1,2}\/\d{4}T\d{1,2}:\d{2}/ {
										   reject if (split('/',$_VAL_))[0]>12;
                                      	   reject if (split('/',$_VAL_))[1]>31;
                                      	   reject if (split('[T:]',$_VAL_))[1]>23;
                                      	   reject if (split('[T:]',$_VAL_))[2]>59;
											} ]

--field <field:/TO|TI|HO|HI|DO|DI|WC|Heat|BR|gust_dir|gust_speed|avg_dir|avg_speed/>	field to edit (must be TO, TI, HO, HI, DO, DI, WC, Heat, BR, gust_dir, gust_speed, avg_dir, or avg_speed) [required]

--totime <totime:datetime>	ending date_time (mm/dd/yyyyThh:mm) [required]

--fromtime <fromtime:datetime>	starting date_time (mm/dd/yyyyThh:mm) [required]

);

my $args = new Getopt::Declare($specification);

die if !$args;

my %args;
$args{'field'} = $args->{'--field'};
$args{'fromtime'} = $args->{'--fromtime'};
$args{'totime'} = $args->{'--totime'};
my $ptr = $flds{$args{field}};

#--------------------------------------------------------------
#	End of Read in arguments
#--------------------------------------------------------------

my $begdate = [(split(/[\/T]+/,$args{fromtime}))[2,0,1]];
my $enddate = [(split(/[\/T]+/,$args{totime}))[2,0,1]];
my $begt = (split(/T/,$args{fromtime}))[1];
my $endt = (split(/T/,$args{totime}))[1];

my @times = map {['00:00','24:00']} (0..Delta_Days(@$begdate, @$enddate));
$times[0]->[0] = $begt;
$times[-1]->[1] = $endt;

for (my $i=0; $i<= Delta_Days(@$begdate, @$enddate); $i++) {
	my $tmin = sec($times[$i]->[0]);
	my $tmax = sec($times[$i]->[1]);
	my $minmax = 0;
	if ($tmin < 5 && $tmax > 1435) {$minmax = 1;}
	my ($y, $m, $d) = Add_Delta_Days(@$begdate, $i);

	#	open and read a file, edit, and replace

	open(IN,"<pack_$m-$d-$y") || die "Can't open pack_$m-$d-$y, $!\n";
	my @output;
	my $flag=0;
	push @output, "## Edited";
	while (<IN>) {
		chomp;
		my @f = split(/\s+/);
		if ($f[0] eq $args{field} && $minmax) { # reset min/max
			$f[2] = $f[6] = '-999.0';
			$_ = join(' ',@f);
		}
		$flag = 1 if /other data/;
		if ($flag && /^\d/) { # reset 10-minute data
			my $t = sec($f[0]);
			if ($t>=$tmin && $t <= $tmax) {
				$f[$ptr] = '-999.0';
				$_ = join(' ',@f);
			}
		}
		push @output, $_;
	}
	# write out new file, and then replace old one.
	close(IN);
	open(OUT,">tempfile") || die "Can't open tempfile, $!\n";
	print OUT join("\n",@output),"\n";
	close OUT;
	rename "pack_$m-$d-$y", "old_pack_$m-$d-$y" ;
	rename "tempfile", "pack_$m-$d-$y";
}

sub sec {
	my $time = shift;
	my ($hr, $min) = split(/:/,$time);
	return 60*$hr+$min;
}
