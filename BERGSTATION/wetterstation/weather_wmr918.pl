####################################################
# Example usage:
#
#  $wmr918 = new  Serial_Item(undef, undef, 'serial2');
#  &read_wmr918($data, \%weather) if $data = said $wmr918;
#
####################################################

# Category=Weather

      # Parse wmr918 datastream into array pointed at with $wptr
      # Lots of good info on the WX200 from:  http://wx200.planetfall.com/

      # Set up array of data types, including group index,
      # group name, length of data, and relevant subroutine
my %wx_datatype = (0x00 => ['wind',  9, \&wr_wind],
                   0x01 => ['rain',  14, \&wr_rain],
                   0x03 => ['outdoor', 7, \&wr_outdoor],
                   0x05 => ['indoor',  11, \&wr_indoor],
                   0x06 => ['indoor',  12, \&wr_indoornew],
                   0x0e => ['minutes',  3, \&wr_minutes],
                   0x0f => ['date',  6, \&wr_date],
				   0xff => ['null' , 1, \&wr_null],
				   );

my %Forecast = ( 0x0c => 'Sunny',
                 0x06 => 'Partly Sunny',
				 0x02 => 'Cloudy',
				 0x03 => 'Rain',
                );

sub read_wmr918 {
    my ($data, $wptr, $debug) = @_;

    my @data = unpack('C*', $data);
	printf("Input : "."%x "x$#data."\n",@data) if $debug;

    while (@data) {
		# Ausschau halten nach den FF FF Inits und die Einträge trimmen (inkl. FF...)
		# Für den Fall, dass wir das Sync verlieren, wird ein Eintrag verworfen
		# und resynchronisiert
		my ($trim, $cnt) = (0,0);
		foreach (@data) {
			last if $cnt >= 2;
			$trim++;
			if ($_ == 0xff) {
				$cnt++
			}
			else {$cnt = 0;} # wir wollen nur aufeinanderfolgende FFs
		}
		if ($trim == @data) {$trim=0;}
		if ($trim > 2 && $debug) {
			print STDERR "===> trim = $trim\n";
			print STDERR "===> ",join(' : ',@data),"\n";
		}
		splice(@data,0,$trim) ; # Weg mit den FF FF Feldern
        my $group = $data[0];
print "XXX group=" . $data[0] . "\n";
        my $dtp = $wx_datatype{$group};
print "XXX wx_datatype group=" . $wx_datatype{$group} . "\n";
#		print "xxx\n";
#		print $group;
#		print "xxx\n";
#		print $wx_datatype{$group}[0];
#		print "xxx\n";

        # Datentyp validieren
        unless ($dtp) {
            my $length = @data;
            printf STDERR ("Bad weather data.  group=%x length=$length\n", $group);
	    print STDERR "---> ",join(' : ',@data),"\n";
            return;
        }
        # Wenn wir nicht genügende Daten bekommen haben: Wieder packen und zurück mit in die
        # Schleife für den nächsten Durchlauf...
        if ($$dtp[1] > @data) {
            return pack('C*', @data);
        }

        # Die Anzahl der Bytes rausziehen, die wir für diesen Typ brauchen
        my @data2 = splice(@data, 0, $$dtp[1]);

        # Auch die Checksumme will gecheckt werden :-)
        my $checksum1 = pop @data2;
        my $checksum2 = -2;
        for (@data2) {
            $checksum2 += $_;
        }
        $checksum2 &= 0xff;     # Checksumme ist kleiner 8 bit der Summe
        if ($checksum1 != $checksum2) {
            print "Achtung! Falsche Checksumme von WMR918 type=$$dtp[0] checksum: cs1=$checksum1 cs2=$checksum2\n";
            next;
        }
	# Daten verarbeiten
        #print "process data $$dtp[0], $$dtp[1]\n";
        &{$$dtp[2]}($wptr, $debug, @data2);
		$$wptr{Group} = $$dtp[0]; # wen oder was hab ich gerade bearbeitet :-?
    }
	return;
}

sub wr_null {
	return;
}

sub wr_outdoor {
    my ($wptr, $debug, @data) = @_;
    $$wptr{F1Outdoor} = sprintf('%x', $data[1]);
    $$wptr{HumidOutdoor} = sprintf('%x', $data[4]);
    $$wptr{TempOutdoor} = (0x80 & $data[3]? -1 : 1) * sprintf('%x%02x', 0x0f & $data[3], $data[2])/10;
    $$wptr{DewOutdoor} =  sprintf('%x', $data[5]);
    print "outdoor humidity = $$wptr{HumidOutdoor}  outdoor temp = $$wptr{TempOutdoor}, dew = $$wptr{DewOutdoor}\n"
		if $debug;
}

sub wr_indoor {
    my ($wptr, $debug, @data) = @_;
    $$wptr{F1Indoor} = sprintf('%x', $data[1]);
    $$wptr{HumidIndoor}  = sprintf('%x', $data[4]);
    $$wptr{TempIndoor} = (0x80 & $data[3]? -1 : 1) * sprintf('%x%02x', 0x0f & $data[3], $data[2])/10;
    $$wptr{DewIndoor} = sprintf('%02x', $data[5]);
    $$wptr{Barom} = sprintf('%2d',$data[6]) + sprintf('%02x%x', $data[9], 0xf0 & $data[8])/10;
    #$$wptr{BaromSea} = sprintf('%x%02x%02x', 0x0f & $data[5], $data[4], $data[3]);
    $$wptr{Forecast}  =  $Forecast{(0x0f & $data[7])};
    $$wptr{F7Indoor} = sprintf('%x', 0xf0 & $data[7]);
    $$wptr{F8Indoor} = sprintf('%x', 0xf0 & $data[8]);
    print "F1 = $$wptr{F1Indoor}, barom = $$wptr{Barom}, dew=$$wptr{DewIndoor}, humid=$$wptr{HumidIndoor}, temp indoor=$$wptr{TempIndoor}\n"  if $debug;
}

sub wr_indoornew {
    my ($wptr, $debug, @data) = @_;
	print "\n----------------------------------------------------------\n";
	print $data[1] . "\n";
	print $data[2] . "\n";
	print $data[3] . "\n";
	print $data[4] . "\n";
	print $data[5] . "\n";
	print $data[6] . "\n";
	print $data[7] . "\n";
	print $data[8] . "\n";
	print $data[9] . "\n";
	print "\n----------------------------------------------------------\n";
	print @data;
	print "\n----------------------------------------------------------\n";

    $$wptr{F1Indoor} = sprintf('%x', $data[1]);
    $$wptr{HumidIndoor}  = sprintf('%x', $data[4]);
    $$wptr{TempIndoor} = (0x80 & $data[3]? -1 : 1) * sprintf('%x%02x', 0x0f & $data[3], $data[2])/10;
    $$wptr{DewIndoor} = sprintf('%02x', $data[5]);
#	$$wptr{Barom} = sprintf('%2d',$data[6]) + sprintf('%02x%x', $data[9], 0xf0 & $data[8])/10;
	$$wptr{Barom} = sprintf('%2d',$data[6]) + 856;
    #$$wptr{BaromSea} = sprintf('%x%02x%02x', 0x0f & $data[5], $data[4], $data[3]);
    #$$wptr{Forecast}  =  $Forecast{(0x80 & $data[7])};
    $$wptr{F7Indoor} = sprintf('%x', 0xf0 & $data[7]);
    $$wptr{F8Indoor} = sprintf('%x', 0xf0 & $data[8]);
    print "F1 = $$wptr{F1Indoor}, barom = $$wptr{Barom}, dew=$$wptr{DewIndoor}, humid=$$wptr{HumidIndoor}, temp indoor=$$wptr{TempIndoor}\n"  if $debug;
}

sub wr_rain {
    my ($wptr, $debug, @data) = @_;
    $$wptr{F1Rain} = sprintf('%x', $data[1]);
    $$wptr{F3Rain} = sprintf('%x', 0xf0 & $data[3]);
    $$wptr{RainRate} = sprintf('%x%02x', 0x0f & $data[3], $data[2]);
    $$wptr{RainTotal} = sprintf('%x%02x',        $data[5], $data[4]);
    $$wptr{RainYest} = sprintf('%x%02x',        $data[7], $data[6]);
    $$wptr{ResetDateTime} = sprintf("%02x:%02x:%02x/%02x/%02x",@data[8..12]);
    print "rain = $$wptr{RainRate}, $$wptr{RainYest}, $$wptr{RainTotal}\n"  if $debug;

    $$wptr{SummaryRain} = sprintf("Rain Recent/Total: %3.1f / %4.1f  Barom: %4d",
                                  $$wptr{RainYest}, $$wptr{RainTotal}, $$wptr{Barom});

}

sub wr_wind {
    my ($wptr, $debug, @data) = @_;
    $$wptr{F1Wind} = sprintf('%x', $data[1]);
    $$wptr{WindGustDir} = sprintf('%x%02x', 0x0f & $data[3], $data[2]);

	#my $abcd = sprintf('%x%02x', 0x0f & $data[3], $data[2]);
	#print "\noo " . $abcd . "oo\n";
	#$abcd = sprintf('%07x', $data[1]);
	#print "aoo " . $abcd . "oo\n";
	#print "boo " . $data[1] . "oo\n";

	
    $$wptr{WindGustSpeed} = sprintf('%02x.%x', $data[4], 0xf0 & $data[3]);
    $$wptr{WindAvgSpeed}  = sprintf('%x%02x', 0x0f & $data[6], $data[5])/10;
    $$wptr{WindChill} = (0xf0 & $data[6]? -1 : 1) * sprintf('%02x', $data[7]);

    print "wind = $$wptr{WindGustSpeed}\n" if $debug;
}
sub wr_minutes {
    my ($wptr, $debug, @data) = @_;
    $$wptr{Minutes}  = sprintf('%x', $data[1]);
    print "minutes = $$wptr{Minutes}\n"  if $debug;

    open MTF, ">", "/var/www/BERGSTATION/wetterstation/WSTIME.sema";
    print MTF "ping";
    close(MTF);

	#print $data[1] . "data1\n";

	#my $abcd = sprintf('%x', $data[1]);
	#print "\ntt " . $abcd . "tt\n";
	#$abcd = sprintf('%x', $data[0]);
	#print "\ntt " . $abcd . "tt\n";
	#$abcd = sprintf('%x', $data[2]);
	#print "\ntt " . $abcd . "tt\n";
	#$abcd = sprintf('%07x', $data[1]);
	#print "att " . $abcd . "tt\n";
	#print "btt " . $data[1] . "tt\n";

	#print "\n";
	#foreach(@data) { print $_ . ".."; }
	#print "\n";
	#print "\n";
	#foreach($data[1]) { print $_ . ".."; }
	#print "\n";
}

sub wr_date {
    my ($wptr, $debug, @data) = @_;
    $$wptr{F1Date} = sprintf('%x', $data[1]);
    $$wptr{'HH:MMDDYY'}  = sprintf("%02x:%02x/%02x/%02x", @data[2..5]);
    print "HH:MMDDYY = $$wptr{'HH:MMDDYY'}\n"  if $debug;
}


=head1

Protocol for the Oregon Scientific WMR-918 weather station
7/21/2000
Alan K. Jackson (alan@ajackson.org)

This document is placed under GPL. Please feel free to use and abuse it, but
give me credit for puzzling it out. Thanks!

Thanks to the creators of the WX200 protocol document. I have tried to follow
their format in preparing this document.

The data stream reacords are directly tied to the sensors themselves, and probably
represent, at least for the most part, the raw data as it is received by the
weather station. Most (all?) quantities calculated by the weather station are not
in fact sent down the RS-232 port.

Records are separated by a 2-byte field of all one's (FFFF).
There are 5 record types. The first byte in each record is the type flag.


Byte   Nibble Bit(s)  Datum   Description 'part' of lo<format<hi unit @ resolution

00. 0  HH     all     Group   00 -------------------------------------------------
00. 1  ??     ???     Wind    ????????? unknown
00. 2  DD     all     Wind    Gust Dir    'bc' of 0<abc<359 degrees @ 1
00. 3  xD     all     Wind    Gust Dir     'a' of 0<abc<359 degrees @ 1
00. 3  Dx     all     Wind    Gust Speed   'c' of 0<ab.c<56 m/s @ 0.2
00. 4  DD     all     Wind    Gust Speed  'ab' of 0<ab.c<56 m/s @ 0.2
00. 5  DD     all     Wind    Avg Speed   'bc' of 0<ab.c<56 m/s @ 0.2
00. 6  xD     all     Wind    Avg Speed    'a' of 0<ab.c<56 m/s @ 0.2
00. 6  Bx      3      Wind    Sign of wind chill, 1 = negative
00. 7  DD     all     Wind    Wind chill  'ab' of -85<ab<60 deg C @ 1
00. 8  HH     all     Cksum   unsigned sum of first 8 bytes +2

01. 0  HH     all     Group   01 ------------------------------------------------
01. 1  ??     ???     Rain    ????????? unknown
01. 2  DD     all     Rain    Rate:       'bc' of 0<abc<999 mm/hr @ 1
01. 3  xD     all     Rain    Rate:        'a' of 0<abc<999 mm/hr @ 1
01. 3  Dx     all     Rain    Bucket tips since ?
01. 4  DD     all     Rain    Total:      'cd' of 0<abcd<9999 mm @ 1
01. 5  DD     all     Rain    Total:      'ab' of 0<abcd<9999 mm @ 1
01. 6  DD     all     Rain    Yesterday:  'cd' of 0<abcd<9999 mm @ 1
01. 7  DD     all     Rain    Yesterday:  'ab' of 0<abcd<9999 mm @ 1
01. 8  DD     all     Rain    Total Reset: Minutes
01. 9  DD     all     Rain    Total Reset: Hours (0<aa<24)
01.10  DD     all     Rain    Total Reset: Day
01.11  DD     all     Rain    Total Reset: Month
01.12  DD     all     Rain    Total Reset: Year
01.13  HH     all     Cksum   unsigned sum of first 13 bytes +2

03. 0  HH     all     Group   03 ------------------------------------------------
03. 1  ??     ???     Outdoor ????????? unknown
03. 2  DD     all     Outdoor Temp        'bc' of -50<ab.c<70 deg C @ 0.1
03. 3  xD     all     Outdoor Temp         'a' of -50<ab.c<70 deg C @ 0.1
03. 3  Bx      3      Outdoor Temp        sign bit. + if 0, - if 1
03. 4  DD     all     Outdoor Humidity    'ab' of 2<ab<98 % RH @ 1.0
03. 5  DD     all     Outdoor Dewpoint    'ab' of 0<ab<56 deg C @ 1.0
03. 6  HH     all     Cksum   unsigned sum of first 6 bytes +2

05. 0  HH     all     Group   05 ------------------------------------------------
05. 1  ??     ???     Indoor  ????????? unknown
05. 2  DD     all     Indoor  Temp        'bc' of -50<ab.c<70 deg C @ 0.1
05. 3  xD     all     Indoor  Temp         'a' of -50<ab.c<70 deg C @ 0.1
05. 3  Bx      3      Indoor  Temp        sign bit. + if 0, - if 1
05. 4  DD     all     Indoor  Humidity    'ab' of 2<ab<98 % RH @ 1.0
05. 5  DD     all     Indoor  Dewpoint    'ab' of 0<ab<47 deg C @ 1.0
05. 6  HH     all     Indoor  Barom P     'ab' of 795<ab+cde<1050 mb @ 1.0
05. 7  xB     1,2     Forecast: C=Sunny, 6=Partly Sunny, 2=Cloudy, 3=Rain
05. 7  ?x     ???     unknown
05. 8  Dx     all     Indoor  Barom P      'c' of 795<ab+cde<1050 mb @ 1.0
05. 8  x?     all     Indoor  Barom P     unknown
05. 9  DD     all     Indoor  Barom P     'de' of 795<ab+cde<1050 mb @ 1.0
03.10  HH     all     Cksum   unsigned sum of first 10 bytes +2

0E. 0  HH     all     Group   0E ------------------------------------------------
0E. 1  DD     all     Time    Minutes field from time display
0E. 2  HH     all     Cksum   unsigned sum of first 2 bytes -2

0F. 0  HH     all     Group   0F ------------------------------------------------
0F. 1  DD     all     Date    ??????????? unknown
0F. 2  DD     all     Date    Hour        'ab' of 0<ab<23 hours @ 1
0F. 3  DD     all     Date    Month       'ab' of 1<ab<12 months @ 1
0F. 4  DD     all     Date    Day         'ab' of 1<ab<31 days @ 1
0F. 5  DD     all     Date    Year        'ab' of 0<ab<99 Year @ 1
0F. 6  HH     all     Cksum   unsigned sum of first 2 bytes -2

Note: c and bb of barometric pressure get revised by sealevel adjustments.

=============================================================================

Nibble Column :
  D -> 4 bit decimal number Range 0-9
  H -> 4 bit hex number Range 0-15
  B -> Bit encoded value
  x -> not defined in this entry

Bits column :
  Bits within defined Nibbles
  0 - Lo order
  3 - Hi order

All data sent in units shown and is independent of the units selected.
Data sent 9600 baud, 8n1.

Cksum :
Last byte in each group is a checksum of that group. It is calculated by performimg
an unsigned add of all the bytes in the group including the group number, excluding
the checksum itself, and subtracting 2 from the result. The checksum is the low order
byte of the sum.

The date field (0F) only gets sent if the chime is set 'on' on the base unit.


Credits :

	I had gotten about 90% of the decoding done when I found John Stanley's
	webpage with his decoding and software. I have incorporated a few things
	that John worked out, but have left mine in where we disagree. John Covert
	also posted a note decoding the Forecast byte.
=cut
