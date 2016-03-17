#!/usr/bin/perl

use LWP::Simple;

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time); $mon++;
$year += 1900;
if ($hour eq "24")      { $hour = "0"; }
if ($min eq "1")       {  $min = "999"; }
if ($min eq "0")       {  $min = "999"; }
$zday = $mday;
if (length($zday) < 2) { $zday = "0$zday"; }
$zmon = $mon;
if (length($zmon) < 2) { $zmon = "0$zmon"; }


$soundfile_phone = "/var/www/BERGSTATION/soundfiles/phone";
$soundfile_radio = "/var/www/BERGSTATION/soundfiles/funk";
$op = "/var/spool/voice/messages";
$of = "/var/www/BERGSTATION/soundfiles/funk";
$jwp  = "/var/www/BERGSTATION/PHONE.wav";
$jwf  = "/var/www/BERGSTATION/FUNK.wav";

# These wave files include no sound at various lengths.
$soundfile_pause0	= "/p0.mus.wav";
$soundfile_pause2	= "/p0.mus.wav";
$soundfile_pause3	= "/p3.mus.wav";
$soundfile_pause5	= "/p5.mus.wav";
$soundfile_pause7	= "/p7.mus.wav";

$soundfile_outOfOrder	= "/out-of-order.mus.wav";

$soundfile_currentWindspeed	= "/w-aktuell.mus.wav";
$soundfile_lastTwentyMinutesWindspeed	= "/w-20.mus.wav";
$soundfile_windspeedOneHourAgo	= "/w-1h.mus.wav";
$soundfile_gust	= "/boe1.mus.wav";
$soundfile_outOfOrder = "/out-of-order.mus.wav";
#$soundfile_jhv = "/jhv-7200.wav";

#$soundfile_timePrefix		= "/es-ist.mus.wav";
#$soundfile_timeInfix 		= "/uhr.mus.wav";

$stager		= "/stager.mus.wav";
$soundfile_hello	= "/indi.mus.wav";
$soundfile_bye		= "/bye.mus.wav";

$soundfile_workToDo		= "/we-ae.mus.wav";
$soundfile_website	= "/www.mus.wav";

$soundfile_kmh		= "/kmh.mus.wav";

$soundfile_windDirection_n		= "/r-n.mus.wav";
$soundfile_windDirection_no		= "/r-no.mus.wav";
$soundfile_windDirection_nno		= "/r-nno.mus.wav";
$soundfile_windDirection_nnw		= "/r-nnw.mus.wav";
$soundfile_windDirection_o		= "/r-o.mus.wav";
$soundfile_windDirection_oso		= "/r-oso.mus.wav";
$soundfile_windDirection_ono		= "/r-ono.mus.wav";
$soundfile_windDirection_so		= "/r-so.mus.wav";
$soundfile_windDirection_s		= "/r-s.mus.wav";
$soundfile_windDirection_sso		= "/r-sso.mus.wav";
$soundfile_windDirection_ssw		= "/r-ssw.mus.wav";
$soundfile_windDirection_sw		= "/r-sw.mus.wav";
$soundfile_windDirection_w		= "/r-w.mus.wav";
$soundfile_windDirection_wsw		= "/r-wsw.mus.wav";
$soundfile_windDirection_wnw		= "/r-wnw.mus.wav";
$soundfile_windDirection_nw		= "/r-nw.mus.wav";

@windspeed = ();
@ws[0] = "/0.mus.wav";
@ws[1] = "/1.mus.wav";
@ws[2] = "/2.mus.wav";
@ws[3] = "/3.mus.wav";
@ws[4] = "/4.mus.wav";
@ws[5] = "/5.mus.wav";
@ws[6] = "/6.mus.wav";
@ws[7] = "/7.mus.wav";
@ws[8] = "/8.mus.wav";
@ws[9] = "/9.mus.wav";
@ws[10] = "/10.mus.wav";
@ws[11] = "/11.mus.wav";
@ws[12] = "/12.mus.wav";
@ws[13] = "/13.mus.wav";
@ws[14] = "/14.mus.wav";
@ws[15] = "/15.mus.wav";
@ws[16] = "/16.mus.wav";
@ws[17] = "/17.mus.wav";
@ws[18] = "/18.mus.wav";
@ws[19] = "/19.mus.wav";
@ws[20] = "/20.mus.wav";
@ws[21] = "/21.mus.wav";
@ws[22] = "/22.mus.wav";
@ws[23] = "/23.mus.wav";
@ws[24] = "/24.mus.wav";
@ws[25] = "/25.mus.wav";
@ws[26] = "/26.mus.wav";
@ws[27] = "/27.mus.wav";
@ws[28] = "/28.mus.wav";
@ws[29] = "/29.mus.wav";
@ws[30] = "/30.mus.wav";
@ws[31] = "/31.mus.wav";
@ws[32] = "/32.mus.wav";
@ws[33] = "/33.mus.wav";
@ws[34] = "/34.mus.wav";
@ws[35] = "/35.mus.wav";
@ws[36] = "/36.mus.wav";
@ws[37] = "/37.mus.wav";
@ws[38] = "/38.mus.wav";
@ws[39] = "/39.mus.wav";
@ws[40] = "/40.mus.wav";
@ws[41] = "/41.mus.wav";
@ws[42] = "/42.mus.wav";
@ws[43] = "/43.mus.wav";
@ws[44] = "/44.mus.wav";
@ws[45] = "/45.mus.wav";
@ws[46] = "/46.mus.wav";
@ws[47] = "/47.mus.wav";
@ws[48] = "/48.mus.wav";
@ws[49] = "/49.mus.wav";
@ws[50] = "/50.mus.wav";
@ws[51] = "/51.mus.wav";
@ws[52] = "/52.mus.wav";
@ws[53] = "/53.mus.wav";
@ws[54] = "/53.mus.wav"; # !!
@ws[55] = "/53.mus.wav"; # !!
@ws[56] = "/58.mus.wav"; # !!
@ws[57] = "/58.mus.wav"; # !!
@ws[58] = "/58.mus.wav";
@ws[59] = "/58.mus.wav"; # !!
@ws[60] = "/64.mus.wav"; # !!
@ws[61] = "/64.mus.wav"; # !!
@ws[62] = "/64.mus.wav"; # !!
@ws[63] = "/64.mus.wav"; # !!
@ws[64] = "/64.mus.wav";
@ws[65] = "/66.mus.wav"; # !!
@ws[66] = "/66.mus.wav";
@ws[67] = "/66.mus.wav"; # !!
@ws[68] = "/70.mus.wav"; # !!
@ws[69] = "/70.mus.wav"; # !!
@ws[70] = "/70.mus.wav";
@ws[71] = "/70.mus.wav"; # !!
@ws[72] = "/72.mus.wav";
@ws[73] = "/72.mus.wav"; # !!
@ws[74] = "/74.mus.wav";
@ws[75] = "/74.mus.wav"; # !!
@ws[76] = "/74.mus.wav"; # !!
@ws[77] = "/79.mus.wav"; # !!
@ws[78] = "/79.mus.wav"; # !!
@ws[79] = "/79.mus.wav";
@ws[80] = "/80.mus.wav";
@ws[81] = "/81.mus.wav";
@ws[82] = "/82.mus.wav";
@ws[83] = "/83.mus.wav";
@ws[84] = "/84.mus.wav";
@ws[85] = "/85.mus.wav";
@ws[86] = "/86.mus.wav";
@ws[87] = "/87.mus.wav";
@ws[88] = "/88.mus.wav";
@ws[89] = "/89.mus.wav";
@ws[90] = "/90.mus.wav";
@ws[91] = "/91.mus.wav";
@ws[92] = "/92.mus.wav";
@ws[93] = "/93.mus.wav";
@ws[94] = "/94.mus.wav";
@ws[95] = "/95.mus.wav";
@ws[96] = "/96.mus.wav";
@ws[97] = "/97.mus.wav";
@ws[98] = "/98.mus.wav";
@ws[99] = "/99.mus.wav";
@ws[999] = "/eins.mus.wav";
$soundfile_onehundred = "/100.mus.wav";
$soundfile_deviceFrozen = "/eis2.wav";
#$soundfile_jhv2010 = "/jhv2010.wav";

@args_phone = ("/usr/bin/shnjoin");
@args_radio = ("/usr/bin/shnjoin");

push @args_phone,"-Oalways";
push @args_radio,"-Oalways";
push @args_phone,"-aPHONE";
push @args_radio,"-aFUNK";
push @args_phone,"-d/var/www/BERGSTATION/";
push @args_radio,"-d/var/www/BERGSTATION/";
push @args_phone,"-rnone";
push @args_radio,"-rnone";
push @args_phone,"-q";
push @args_radio,"-q";

### Greeting
AddToSoundfile($soundfile_hello, "both", 3);

### Collect and parse data
$content = get("http://localhost:81/wetterstation/phone_neu.php");

($akt,$twenty,$hourly,$maxi) = split("x",$content);

($a1,$a2,$a3) = split(",",$akt);
print time;
print "\n";
print $a3;
print "\n";
print time - $a3;
print "\n";

### Check age of last data and announce out of order
if ((time - $a3) > 2300) {
    AddToSoundfile($soundfile_outOfOrder, "both", 3);
    print "WS gone?";
#} elsif ($a1 == 0) {
#    push @args_phone,$soundfile_phone.$soundfile_deviceFrozen;
#		push @args_radio,$soundfile_radio . $soundfile_deviceFrozen;
#    print "EIS???";
} else {
    
    #### Current windspeed
    
    AddToSoundfile($soundfile_currentWindspeed, "both", 2);     # Aktuelle Windstärke:
    AddToSoundfile(&wdirection($a2), "both", 2);                # (Windrichtung)
	if (length($a1) == 3) {
        AddToSoundfile($soundfile_onehundred, "both", 0);       # einhundert ...
        AddToSoundfile($ws[substr($a1,1,2)], "both", 0);        # (Windgeschwindigkeit)
    }  else {
        AddToSoundfile($ws[$a1], "both", 0);                    # (Windgeschwindigkeit)
    }
    AddToSoundfile($soundfile_kmh, "both", 3);                  # km/h.
    
    
    ### Last 20 minutes average windspeed
    AddToSoundfile($soundfile_lastTwentyMinutesWindspeed,
    "both", 2);                                                 # Durchschnittlicher Wind der letzten 20 Minuten:
    ($a1,$a2) = split(",",$twenty);
    AddToSoundfile(&wdirection($a2), "both", 2);                # (Windrichtung)
    if (length($a1) == 3) {
        AddToSoundfile($soundfile_onehundred, "both", 0);       # einhundert ...
        AddToSoundfile($ws[substr($a1,1,2)], "both", 0);        # (Windgeschwindigkeit)
    }  else {
         AddToSoundfile($ws[$a1], "both", 0);                   # (Windgeschwindigkeit)
    }
    AddToSoundfile($soundfile_kmh, "both", 3);                  # km/h.

    
    ### Strongest gust last 20 minutes
    AddToSoundfile($soundfile_gust, "both", 2);                 # Stärkste Windböe der letzten 20 Minuten:
    ($a1,$a2) = split(",",$maxi);
    $a2 =~ s/[^0-9]//igs;
    $dummywd = &wdirection($a2);
    AddToSoundfile($dummywd, "both", 2);                        # (Windrichtung)
    if (length($a1) == 3) {
            AddToSoundfile($soundfile_onehundred, "both", 0);   # einhundert ...
            AddToSoundfile($ws[substr($a1,1,2)], "both", 0);    # (Windgeschwindigkeit)

    }  else {
        AddToSoundfile($ws[$a1], "both", 0);                    # (Windgeschwindigkeit)
    }
    AddToSoundfile($soundfile_kmh, "both", 3);                  # km/h.


    ### Wind 1h ago
    AddToSoundfile($soundfile_windspeedOneHourAgo, "both", 2);  # Wind genau vor einer Stunde:
		    ($a1,$a2) = split(",",$hourly);
    AddToSoundfile(&wdirection($a2), "both", 2);                # (Windrichtung)
    if (length($a1) == 3) {
        AddToSoundfile($soundfile_onehundred, "both", 0);       # einhundert ...
        AddToSoundfile($ws[substr($a1,1,2)], "both", 0);        # (Windgeschwindigkeit)
        
    }  else {
        AddToSoundfile($ws[$a1], "both", 0);                    # (Windgeschwindigkeit)
    }
    AddToSoundfile($soundfile_kmh, "both", 3);                  # km/h.

    ### Current time
    #AddToSoundfile($soundfile_timePrefix, "phone", 0);           # Es ist
    #AddToSoundfile($ws[$hour], "phone", 0);                      # (Stunde)
    #AddToSoundfile($soundfile_timeInfix, "phone", 0);            # Uhr
    #AddToSoundfile($ws[$min], "phone", 3);                       # (Minute)
    
}


### Say Goodbye
AddToSoundfile($soundfile_bye, "both", 0);


#print "\n\n";
#foreach (@args_phone) {
# 	print $_;
#	print " ";
# } 
#print "\n\n";

system(@args_phone) == 0;
#    or die "system @args failed: $?";
	
if ($? == -1) {
print "failed to execute: $!\n";
}
elsif ($? & 127) {
printf "child died with signal %d, %s coredump\n",
($? & 127), ($? & 128) ? 'with' : 'without';
}
else {
printf "child exited with value %d\n", $? >> 8;
}	
####################
system(@args_radio) == 0;
#    or die "system @args failed: $?";
	
if ($? == -1) {
print "failed to execute: $!\n";
}
elsif ($? & 127) {
printf "child died with signal %d, %s coredump\n",
($? & 127), ($? & 128) ? 'with' : 'without';
}
else {
printf "child exited with value %d\n", $? >> 8;
}	
####################		
	
	

#system(@args_radio) == 0
 #   or die "system @args failed: $?";
	
	
#print "wavtopvf $jwp | pvfspeed -s 7200 | pvftormd Elsa 4 > $op/indikativ.rmd";
system("wavtopvf $jwp | pvfspeed -s 7200 | pvftormd Elsa 4 > $op/indikativ.rmd");


sub wdirection() {
    my $wdin = $_[0];
    #print "x " . $wdin . "...";
    if ($wdin >= 349 && $wdin <= 360) { $wi = $soundfile_windDirection_n; }
    if ($wdin <= 11) { $wi = $soundfile_windDirection_n; }
    if ($wdin >= 12  && $wdin <= 33  ) { $wi = $soundfile_windDirection_nno; }
    if ($wdin >= 34  && $wdin <= 55  ) { $wi = $soundfile_windDirection_no; }
    if ($wdin >= 56  && $wdin <= 78  ) { $wi = $soundfile_windDirection_ono; }
    if ($wdin >= 79  && $wdin <= 100 ) { $wi = $soundfile_windDirection_o; }
    if ($wdin >= 101 && $wdin <= 123 ) { $wi = $soundfile_windDirection_oso; }
    if ($wdin >= 124 && $wdin <= 145 ) { $wi = $soundfile_windDirection_so; }
    if ($wdin >= 146 && $wdin <= 168 ) { $wi = $soundfile_windDirection_sso; }
    if ($wdin >= 169 && $wdin <= 190 ) { $wi = $soundfile_windDirection_s; }
    if ($wdin >= 191 && $wdin <= 213 ) { $wi = $soundfile_windDirection_ssw; }
    if ($wdin >= 214 && $wdin <= 235 ) { $wi = $soundfile_windDirection_sw; }
    if ($wdin >= 236 && $wdin <= 258 ) { $wi = $soundfile_windDirection_wsw; }
    if ($wdin >= 259 && $wdin <= 280 ) { $wi = $soundfile_windDirection_w; }
    if ($wdin >= 281 && $wdin <= 303 ) { $wi = $soundfile_windDirection_wnw; }
    if ($wdin >= 304 && $wdin <= 325 ) { $wi = $soundfile_windDirection_nw; }
    if ($wdin >= 326 && $wdin <= 348 ) { $wi = $soundfile_windDirection_nnw; }
    #print "$wi\n";
    return $wi;
}

# Append $sound to "phone", "radio" or "both" sound files plus a $pause ms pause.
sub AddToSoundfile
{
    my $sound = shift;
    my $file = shift;
    my $pause = shift;
    my $pauseFile = $soundfile_pause0;
    
    
        if ($pause==0)   {$pauseFile == $soundfile_pause0;}
        if ($pause==2)   {$pauseFile == $soundfile_pause2;}
        if ($pause==3)   {$pauseFile == $soundfile_pause3;}
        if ($pause==5)   {$pauseFile == $soundfile_pause5;}
        if ($pause==7)   {$pauseFile == $soundfile_pause7;}
        else {$pauseFile ==   $soundfile_pause2;}
    
    
    
    if ($file == "phone" || $file == "both" )
    {
        push @args_phone,$soundfile_phone.$sound;
        if ($pause > 0)
        {
            push @args_phone,$soundfile_phone.$pauseFile;}
        

    }
    if ($file == "radio" || $file == "both" )
    {
        push @args_radio,$soundfile_radio.$sound;
        if ($pause > 0){
            push @args_radio,$soundfile_radio.$pauseFile;
        }
    }
    
    
    
    
    
}


