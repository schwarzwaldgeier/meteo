
require Exporter;
package Weather::Conversions;
@ISA=qw(Exporter);
@EXPORT = qw( UnitsTemp UnitsPres UnitsWind UnitsRain );
use strict;


sub UnitsTemp {
	my $c = shift;
	return sprintf("%6.1f",$c*1.8 +32);
}

sub UnitsPres {
	my $mb = shift;
	#return sprintf("%6.2f",$mb*0.0295301);
	return $mb;
}

sub UnitsWind {
	my $mps = shift;
	return sprintf("%6.2f",$mps*2.23694);
}

sub UnitsRain {
	my $mm = shift;
	return sprintf("%6.2f",$mm*0.0393701);
}
