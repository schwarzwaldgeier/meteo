#!/usr/bin/perl

use LWP::Simple;

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time); $mon++;
$year += 1900;
if ($hour eq "24")      { $hour = "0"; }
if ($min eq "1")       {  $min = "999"; }
if ($min eq "0")       {  $hour = "1"; }
$zday = $mday;
if (length($zday) < 2) { $zday = "0$zday"; }
$zmon = $mon;
if (length($zmon) < 2) { $zmon = "0$zmon"; }


$p = "/var/www/BERGSTATION/soundfiles/phone";
$f = "/var/www/BERGSTATION/soundfiles/funk";
$op = "/var/spool/voice/messages";
$of = "/var/www/BERGSTATION/soundfiles/funk";
$jwp  = "/var/www/BERGSTATION/PHONE.wav";
$jwf  = "/var/www/BERGSTATION/FUNK.wav";

$p0	= "/p0.mus.wav";
$p2	= "/p0.mus.wav";
$p3	= "/p3.mus.wav";
$p5	= "/p5.mus.wav";
$p7	= "/p7.mus.wav";

$ooo	= "/out-of-order.mus.wav";

$w_aktuell	= "/w-aktuell.mus.wav";
$w_20min	= "/w-20.mus.wav";
$w_1hour	= "/w-1h.mus.wav";
$w_boe		= "/boe1.mus.wav";
$ooo = "/out-of-order.mus.wav";
$jhv = "/jhv-7200.wav";

$esist		= "/es-ist.mus.wav";
$uhr 		= "/uhr.mus.wav";

$stager		= "/stager.mus.wav";
$greeting	= "/indi.mus.wav";
$bye		= "/bye.mus.wav";

$ae		= "/we-ae.mus.wav";
$wwwgsv		= "/www.mus.wav";

$stamm_mi       = "/mi-sta.mus.wav";
$stamm_today    = "/he-sta.mus.wav";

$kmh		= "/kmh.mus.wav";

$w_n		= "/r-n.mus.wav";
$w_no		= "/r-no.mus.wav";
$w_nno		= "/r-nno.mus.wav";
$w_nnw		= "/r-nnw.mus.wav";
$w_o		= "/r-o.mus.wav";
$w_oso		= "/r-oso.mus.wav";
$w_ono		= "/r-ono.mus.wav";
$w_so		= "/r-so.mus.wav";
$w_s		= "/r-s.mus.wav";
$w_sso		= "/r-sso.mus.wav";
$w_ssw		= "/r-ssw.mus.wav";
$w_sw		= "/r-sw.mus.wav";
$w_w		= "/r-w.mus.wav";
$w_wsw		= "/r-wsw.mus.wav";
$w_wnw		= "/r-wnw.mus.wav";
$w_nw		= "/r-nw.mus.wav";

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
@ws[54] = "/54.mus.wav";
@ws[55] = "/55.mus.wav";
@ws[56] = "/56.mus.wav";
@ws[57] = "/57.mus.wav";
@ws[58] = "/58.mus.wav";
@ws[59] = "/59.mus.wav";
@ws[60] = "/60.mus.wav";
@ws[61] = "/61.mus.wav";
@ws[62] = "/62.mus.wav";
@ws[63] = "/63.mus.wav";
@ws[64] = "/64.mus.wav";
@ws[65] = "/65.mus.wav";
@ws[66] = "/66.mus.wav";
@ws[67] = "/67.mus.wav";
@ws[68] = "/68.mus.wav";
@ws[69] = "/69.mus.wav";
@ws[70] = "/70.mus.wav";
@ws[71] = "/71.mus.wav";
@ws[72] = "/72.mus.wav";
@ws[73] = "/73.mus.wav";
@ws[74] = "/74.mus.wav";
@ws[75] = "/75.mus.wav";
@ws[76] = "/76.mus.wav";
@ws[77] = "/77.mus.wav";
@ws[78] = "/78.mus.wav";
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
$wshunni = "/100.mus.wav";
$eis = "/eis2.wav";
$jhv2010 = "/jhv2010.wav";

@args_phon = ("/usr/bin/shnjoin");
@args_funk = ("/usr/bin/shnjoin");

push @args_phon,"-Oalways";
push @args_funk,"-Oalways";
push @args_phon,"-aPHONE";
push @args_funk,"-aFUNK";
push @args_phon,"-d/var/www/BERGSTATION/";
push @args_funk,"-d/var/www/BERGSTATION/";
push @args_phon,"-rnone";
push @args_funk,"-rnone";
push @args_phon,"-q";
push @args_funk,"-q";

push @args_phon,$p.$greeting;
push @args_funk,$f.$greeting;

$content = get("http://localhost:81/wetterstation/phone.php");

($akt,$twenty,$hourly,$maxi) = split("x",$content);

($a1,$a2,$a3) = split(",",$akt);
print time;
print "\n";
print $a3;
print "\n";
print time - $a3;
print "\n";

if ((time - $a3) > 2300) {
	push @args_phon,$p.$ooo;
		push @args_funk,$f.$ooo;
	print "WS gone?";
#} elsif ($a1 == 0) {
#    push @args_phon,$p.$eis;
#		push @args_funk,$f . $eis;
#    print "EIS???";
} else {
    push @args_phon,$p.$p3;
		push @args_funk,$f.$p3;
    push @args_phon,$p.$w_aktuell;
		push @args_funk,$f.$w_aktuell;
    push @args_phon,$p.$p2;
		push @args_funk,$f.$p2;
    push @args_phon,$p.&wdirection($a2);
		push @args_funk,$f.&wdirection($a2);
    push @args_phon,$p.$p2;
		push @args_funk,$f.$p2;

	if (length($a1) == 3) {
        push @args_phon,$p.$wshunni;
			push @args_funk,$f.$wshunni;
        push @args_phon,$p.$ws[substr($a1,1,2)];
			push @args_funk,$f.$ws[substr($a1,1,2)];
    }  else {
        push @args_phon,$p.$ws[$a1];
			push @args_funk,$f.$ws[$a1];
    }
	
    push @args_phon,$p.$p0;
		push @args_funk,$f.$p0;
    push @args_phon,$p.$kmh;
		push @args_funk,$f.$kmh;
    push @args_phon,$p.$p3;
		push @args_funkn,$f.$p3;

    push @args_phon,$p.$w_20min;
		push @args_funk,$f.$w_20min;
    push @args_phon,$p.$p2;
		push @args_funk,$f.$p2;

    ($a1,$a2) = split(",",$twenty);

    push @args_phon,$p.&wdirection($a2);
		push @args_funk,$f.&wdirection($a2);
    push @args_phon,$p.$p2;
		push @args_funk,$f.$p2;

    if (length($a1) == 3) {
        push @args_phon,$p.$wshunni;
			push @args_funk,$f.$wshunni;
        push @args_phon,$p.$ws[substr($a1,1,2)];
			push @args_funk,$f.$ws[substr($a1,1,2)];
    }  else {
        push @args_phon,$p.$ws[$a1];
			push @args_funk,$f.$ws[$a1];
    }

    push @args_phon,$p.$p0;
		push @args_funk,$f.$p0;
    push @args_phon,$p.$kmh;
		push @args_funk,$f.$kmh;
    push @args_phon,$p.$p3;
		push @args_funk,$f.$p3;

    push @args_phon,$p.$w_boe;
		push @args_funk,$f.$w_boe;
    push @args_phon,$p.$p2;
		push @args_funk,$f.$p2;

    ($a1,$a2) = split(",",$maxi);
    $a2 =~ s/[^0-9]//igs;
    #print "xxx" . $a2 . "xxx\n";
    $dummywd = &wdirection($a2);
    push @args_phon,$p.$dummywd;
		push @args_funk,$f.$dummywd;
    push @args_phon,$p.$p2;
		push @args_funk,$f.$p2;
    if (length($a1) == 3) {
        push @args_phon,$p.$wshunni;
			push @args_funk,$f.$wshunni;
        push @args_phon,$p.$ws[substr($a1,1,2)];
			push @args_funk,$f.$ws[substr($a1,1,2)];
    }  else {
        push @args_phon,$p.$ws[$a1];
			push @args_funk,$f.$ws[$a1];
    }

    push @args_phon,$p.$p0;
		push @args_funk,$f.$p0;
    push @args_phon,$p.$kmh;
		push @args_funk,$f.$kmh;
    push @args_phon,$p.$p3;
		push @args_funk,$f.$p3;
	
    push @args_phon,$p.$w_1hour;
		push @args_funk,$f.$w_1hour;
    push @args_phon,$p.$p2;
		push @args_funk,$f.$p2;
    ($a1,$a2) = split(",",$hourly);
    #print "$a2 lllllll\n";
    push @args_phon,$p.&wdirection($a2);
		push @args_funk,$f.&wdirection($a2);
    push @args_phon,$p.$p2;
		push @args_funk,$f.$p2;

	if (length($a1) == 3) {
        push @args_phon,$p.$wshunni;
			push @args_funk,$f.$wshunni;
        push @args_phon,$p.$ws[substr($a1,1,2)];
			push @args_funk,$f.$ws[substr($a1,1,2)];
    }  else {
        push @args_phon,$p.$ws[$a1];
			push @args_funk,$f.$ws[$a1];
    }
    push @args_phon,$p.$p0;
		push @args_funk,$f.$p0;
    push @args_phon,$p.$kmh;
		push @args_funk,$f.$kmh;
    push @args_phon,$p.$p3;
		push @args_funk,$f.$p3;

    push @args_phon,$p.$esist;
    push @args_phon,$p.$ws[$hour];
    push @args_phon,$p.$uhr;
    push @args_phon,$p.$ws[$min];
    push @args_phon,$p.$p3;
}

if ("$year$zmon$zday" < "20100205") {
    push @args_phon,$p.$jhv2010;
		push @args_funk,$f.$jhv2010;
    print "JHV...";
}

push @args_phon,$p.$bye;
push @args_funk,$f.$bye;

#print "\n\n";
#foreach (@args_phon) {
# 	print $_;
#	print " ";
# } 
#print "\n\n";

system(@args_phon) == 0;
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
system(@args_funk) == 0;
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
	
	

#system(@args_funk) == 0
 #   or die "system @args failed: $?";
	
	
#print "wavtopvf $jwp | pvfspeed -s 7200 | pvftormd Elsa 4 > $op/indikativ.rmd";
system("wavtopvf $jwp | pvfspeed -s 7200 | pvftormd Elsa 4 > $op/indikativ.rmd");


sub wdirection() {
    my $wdin = $_[0];
    #print "x " . $wdin . "...";
    if ($wdin >= 349 && $wdin <= 360) { $wi = $w_n; }
    if ($wdin <= 11) { $wi = $w_n; }
    if ($wdin >= 12  && $wdin <= 33  ) { $wi = $w_nno; }
    if ($wdin >= 34  && $wdin <= 55  ) { $wi = $w_no; }
    if ($wdin >= 56  && $wdin <= 78  ) { $wi = $w_ono; }
    if ($wdin >= 79  && $wdin <= 100 ) { $wi = $w_o; }
    if ($wdin >= 101 && $wdin <= 123 ) { $wi = $w_oso; }
    if ($wdin >= 124 && $wdin <= 145 ) { $wi = $w_so; }
    if ($wdin >= 146 && $wdin <= 168 ) { $wi = $w_sso; }
    if ($wdin >= 169 && $wdin <= 190 ) { $wi = $w_s; }
    if ($wdin >= 191 && $wdin <= 213 ) { $wi = $w_ssw; }
    if ($wdin >= 214 && $wdin <= 235 ) { $wi = $w_sw; }
    if ($wdin >= 236 && $wdin <= 258 ) { $wi = $w_wsw; }
    if ($wdin >= 259 && $wdin <= 280 ) { $wi = $w_w; }
    if ($wdin >= 281 && $wdin <= 303 ) { $wi = $w_wnw; }
    if ($wdin >= 304 && $wdin <= 325 ) { $wi = $w_nw; }
    if ($wdin >= 326 && $wdin <= 348 ) { $wi = $w_nnw; }
    #print "$wi\n";
    return $wi;
}
#wavtopvf joined.wav | pvfspeed -s 7200 | pvftormd Elsa 4 > ../indikativ.rmd

