package Weather::Climate;
use strict;

use Date::Calc qw(
             Delta_Days
             Add_Delta_Days
         );

#
#	Monthly climatological norms for Houston
#	Acquired off the web
#

my %data;

$data{'afternoon_humidity'} = [ qw/60 64 61 59 58 60 60 57 57 60 56 60 62/ ];
$data{'morning_humidity'} = [ qw/90 86 86 87 89 92 92 93 93 93 91 89 87/ ];
$data{'wind_speed'} = [ qw/8.2 8.8 9.3 9.2 8.2 7.8 7 6.3 6.9 7 8 8/ ];
$data{'precip'} = [ qw/3.29 2.96 2.92 3.21 5.24 4.96 3.6 3.49 4.89 4.27 3.79 3.45/ ];
$data{'lowestT'} = [ qw/12 20 22 31 44 52 62 60 48 29 19 7/ ];
$data{'highestT'} = [ qw/84 91 91 95 97 103 104 107 102 96 89 83/ ];
$data{'AvgLowT'} = [ qw/39.7 42.6 50 58.1 64.4 70.6 72.4 72 67.9 57.6 49.6 42.2/ ];
$data{'AvgHighT'} = [ qw/61 65.3 71.1 78.4 84.6 90.1 92.7 92.5 88.4 81.6 72.4 64.7/ ];

my %Dailydata;
$Dailydata{AvgHighT}{January} = [qw/ 61 61 61 61 61 61 61 61 61 61 60 60 60 60 60 60 60 60 60 60 60 61 61 61 61 61 61 61 61 61 61/];
$Dailydata{AvgHighT}{February} = [qw/ 62 62 62 62 62 62 63 63 63 63 63 64 64 64 64 64 65 65 65 65 66 66 66 66 67 67 67 67 68/];
$Dailydata{AvgHighT}{March} = [qw/ 68 68 68 69 69 69 69 70 70 70 70 71 71 71 72 72 72 72 73 73 73 73 74 74 74 74 75 75 75 75 76/];
$Dailydata{AvgHighT}{April} = [qw/ 76 76 76 76 77 77 77 77 78 78 78 78 79 79 79 79 79 80 80 80 80 80 81 81 81 81 81 82 82 82/];
$Dailydata{AvgHighT}{May} = [qw/ 82 82 83 83 83 83 83 84 84 84 84 84 84 85 85 85 85 85 86 86 86 86 86 87 87 87 87 87 87 88 88/];
$Dailydata{AvgHighT}{June} = [qw/ 88 88 88 88 89 89 89 89 89 89 90 90 90 90 90 90 90 91 91 91 91 91 91 91 91 91 92 92 92 92/];
$Dailydata{AvgHighT}{July} = [qw/ 92 92 92 92 92 92 92 92 92 93 93 93 93 93 93 93 93 93 93 93 93 93 93 93 93 93 93 93 93 93 93/];
$Dailydata{AvgHighT}{August} = [qw/ 93 93 93 93 93 93 93 93 93 93 93 93 93 93 93 93 93 93 93 93 93 92 92 92 92 92 92 92 91 91 91/];
$Dailydata{AvgHighT}{September} = [qw/ 91 91 91 91 90 90 90 90 90 89 89 89 89 89 88 88 88 88 88 87 87 87 87 87 86 86 86 86 85 85/];
$Dailydata{AvgHighT}{October} = [qw/ 85 85 84 84 84 84 83 83 83 83 82 82 82 82 81 81 81 81 80 80 80 79 79 79 79 78 78 78 77 77 77/];
$Dailydata{AvgHighT}{November} = [qw/ 76 76 76 76 75 75 75 74 74 74 73 73 73 73 72 72 72 71 71 71 71 70 70 70 69 69 69 69 68 68/];
$Dailydata{AvgHighT}{December} = [qw/ 68 67 67 67 67 66 66 66 66 65 65 65 64 64 64 64 63 63 63 63 62 62 62 62 61 61 61 60 60 60 60/];
$Dailydata{AvgLowT}{January} = [qw/ 41 41 41 41 41 41 40 40 40 40 40 40 40 40 40 40 40 40 40 40 40 40 40 40 40 40 40 41 41 41 41/];
$Dailydata{AvgLowT}{February} = [qw/ 41 41 41 41 41 42 42 42 42 42 42 42 43 43 43 43 43 44 44 44 44 45 45 45 45 46 46 46 46/];
$Dailydata{AvgLowT}{March} = [qw/ 47 47 47 48 48 48 48 49 49 49 50 50 50 51 51 51 51 52 52 52 53 53 53 53 54 54 54 55 55 55 55/];
$Dailydata{AvgLowT}{April} = [qw/ 56 56 56 56 57 57 57 57 58 58 58 59 59 59 59 59 60 60 60 60 61 61 61 61 62 62 62 62 62 63/];
$Dailydata{AvgLowT}{May} = [qw/ 63 63 63 64 64 64 64 64 65 65 65 65 65 66 66 66 66 66 67 67 67 67 67 68 68 68 68 68 69 69 69/];
$Dailydata{AvgLowT}{June} = [qw/ 69 69 69 70 70 70 70 70 70 71 71 71 71 71 71 71 71 72 72 72 72 72 72 72 72 72 72 73 73 73/];
$Dailydata{AvgLowT}{July} = [qw/ 73 73 73 73 73 73 73 73 73 73 73 73 73 73 73 73 73 73 73 73 73 73 73 73 73 73 73 73 73 73 73/];
$Dailydata{AvgLowT}{August} = [qw/ 73 73 73 73 73 73 73 73 73 73 73 73 73 73 73 73 73 73 73 72 72 72 72 72 72 72 72 72 72 72 71/];
$Dailydata{AvgLowT}{September} = [qw/ 71 71 71 71 71 70 70 70 70 70 70 69 69 69 69 68 68 68 67 67 67 67 66 66 66 65 65 65 64 64/];
$Dailydata{AvgLowT}{October} = [qw/ 63 63 63 62 62 62 61 61 61 60 60 60 59 59 59 58 58 58 57 57 57 57 56 56 56 56 55 55 55 55 54/];
$Dailydata{AvgLowT}{November} = [qw/ 54 54 54 53 53 53 53 52 52 52 52 51 51 51 51 51 50 50 50 50 49 49 49 48 48 48 48 47 47 47/];
$Dailydata{AvgLowT}{December} = [qw/ 47 46 46 46 46 45 45 45 44 44 44 44 43 43 43 42 42 42 42 41 41 41 41 40 40 40 39 39 39 39 38/];
$Dailydata{highestT}{January} = [qw/ 83 83 82 83 79 80 84 79 80 81 82 80 80 82 82 81 80 82 82 82 83 80 80 84 82 83 83 83 82 82 81 /];
$Dailydata{highestT}{February} = [qw/ 81 82 81 82 81 82 81 82 82 85 86 80 83 82 82 84 82 84 87 89 87 86 86 84 83 83 87 84 83 /];
$Dailydata{highestT}{March} = [qw/ 85 83 83 84 83 86 86 86 88 86 90 88 86 87 86 85 84 87 86 88 88 86 88 85 88 87 86 87 91 90 92 /];
$Dailydata{highestT}{April} = [qw/ 90 89 85 88 85 91 90 89 91 90 93 90 87 89 91 88 92 92 94 91 92 89 89 89 90 88 92 94 95 91 /];
$Dailydata{highestT}{May} = [qw/ 94 92 95 94 94 93 91 95 95 94 94 94 95 93 92 93 95 95 95 94 95 95 94 94 94 95 95 99 96 96 97 /];
$Dailydata{highestT}{June} = [qw/ 99 99 97 100 97 97 98 98 98 100 100 98 97 99 99 100 99 97 98 99 98 100 100 100 97 99 101 101 99 99 /];
$Dailydata{highestT}{July} = [qw/ 100 102 101 100 100 101 100 101 102 100 103 102 100 100 101 101 103 103 103 103 99 98 98 99 100 101 105 100 100 100 103 /];
$Dailydata{highestT}{August} = [qw/ 103 101 102 102 103 102 102 100 102 104 104 102 105 105 102 102 104 102 102 101 103 103 100 103 100 100 101 102 99 100 102 /];
$Dailydata{highestT}{September} = [qw/ 100 102 100 101 100 99 100 99 98 97 97 98 98 98 97 96 98 98 96 97 100 97 96 96 95 96 95 96 96 96 /];
$Dailydata{highestT}{October} = [qw/ 95 94 98 93 95 92 95 95 96 93 95 94 94 95 93 91 93 92 97 90 92 91 91 90 91 92 92 89 91 92 90 /];
$Dailydata{highestT}{November} = [qw/ 91 88 91 89 90 87 87 87 90 89 89 89 89 88 90 88 85 86 84 87 90 83 86 84 84 86 86 85 84 82 /];
$Dailydata{highestT}{December} = [qw/ 83 88 86 83 82 83 83 84 85 81 79 81 84 90 84 82 82 83 79 81 82 80 80 80 85 82 80 82 80 81 83/];
$Dailydata{lowestT}{January} = [qw/ 24 16 19 22 22 23 19 18 19 15 12 12 19 19 20 23 20 21 20 20 18 19 24 16 19 29 27 28 24 19 6 /];
$Dailydata{lowestT}{February} = [qw/ 9 12 12 22 21 26 24 24 24 24 19 21 23 28 30 28 26 28 25 26 29 29 30 25 24 26 32 32 29 /];
$Dailydata{lowestT}{March} = [qw/ 30 22 21 28 29 25 25 28 31 31 27 25 26 31 32 34 35 32 33 28 32 35 34 34 39 30 30 36 38 36 31 /];
$Dailydata{lowestT}{April} = [qw/ 35 39 32 36 43 40 39 41 36 38 40 41 40 39 40 43 42 41 44 45 42 48 45 46 48 50 50 50 49 47 /];
$Dailydata{lowestT}{May} = [qw/ 47 52 53 48 49 51 52 51 50 52 49 50 50 51 53 54 54 53 55 55 58 59 57 60 59 61 56 51 55 55 55 /];
$Dailydata{lowestT}{June} = [qw/ 59 60 56 57 60 61 64 59 60 57 57 58 61 65 65 60 60 61 60 66 65 66 65 69 60 62 63 62 63 63 /];
$Dailydata{lowestT}{July} = [qw/ 63 66 68 68 65 65 66 65 68 66 68 69 69 64 63 64 63 68 69 71 66 68 67 68 69 70 70 70 69 69 67 /];
$Dailydata{lowestT}{August} = [qw/ 68 69 68 68 67 68 68 70 64 64 65 63 60 64 67 67 64 65 70 67 68 65 62 65 64 65 65 64 64 66 67 /];
$Dailydata{lowestT}{September} = [qw/ 67 67 66 60 54 55 57 61 60 59 63 58 59 62 56 51 55 53 51 54 57 50 50 51 47 50 53 49 48 50 /];
$Dailydata{lowestT}{October} = [qw/ 46 48 47 47 48 46 48 41 42 44 45 44 42 42 45 44 45 44 37 35 36 39 44 41 41 40 36 36 39 30 30 /];
$Dailydata{lowestT}{November} = [qw/ 30 35 29 31 36 36 28 32 32 32 32 34 35 35 29 28 33 26 28 29 31 34 27 26 29 30 26 26 22 24 /];
$Dailydata{lowestT}{December} = [qw/ 26 25 31 32 31 21 15 24 26 21 23 22 21 22 25 17 23 26 23 23 23 16 6 9 11 12 22 29 22 18 18/];
$Dailydata{highestTd}{January} = [qw/ 1952 1952 1982 1989 1955 1989 1989 1965 1957 1948 1963 1989 1948 1952 1949 1949 1952 1952 1950 1952 1952 1982 1950 1972 1949 1950 1950 1972 1975 1975 1971/];
$Dailydata{highestTd}{February} = [qw/ 1975 1989 1974 1957 1957 1957 1950 1950 1950 1962 1957 1976 1957 1962 1956 1956 1956 1986 1986 1986 1986 1996 1996 1996 1977 1986 1986 1996 1948/];
$Dailydata{highestTd}{March} = [qw/ 1955 1951 1955 1955 1955 1951 1949 1951 1951 1951 1980 1956 1955 1949 1967 1955 1948 1972 1953 1982 1982 1982 1971 1948 1954 1955 1976 1984 1972 1974 1989/];
$Dailydata{highestTd}{April} = [qw/ 1948 1974 1956 1963 1957 1982 1948 1948 1986 1963 1963 1963 1948 1972 1996 1972 1987 1987 1987 1987 1981 1948 1963 1958 1958 1955 1948 1948 1948 1948/];
$Dailydata{highestTd}{May} = [qw/ 1947 1949 1964 1947 1951 1947 1947 1998 1967 1978 1998 1947 1967 1990 1978 1963 1948 1948 1948 1950 1996 1990 1948 1948 1955 1958 1958 1996 1958 1996 1998/];
$Dailydata{highestTd}{June} = [qw/ 1998 1998 1960 1960 1960 1977 1977 1948 1948 1948 1948 1950 1948 1963 1998 1949 1998 1952 1960 1996 1980 1949 1949 1949 1978 1980 1980 1980 1950 1950/];
$Dailydata{highestTd}{July} = [qw/ 1980 1949 1980 1952 1980 1980 1980 1949 1980 1969 1949 1949 1980 1980 1980 1980 1980 1980 1951 1951 1951 1982 1948 1977 1954 1964 1954 1951 1951 1960 1948/];
$Dailydata{highestTd}{August} = [qw/ 1948 1998 1998 1951 1951 1951 1951 1947 1947 1947 1962 1948 1962 1962 1948 1948 1948 1951 1948 1948 1999 1948 1948 1980 1951 1951 1990 1990 1951 1951 1954/];
$Dailydata{highestTd}{September} = [qw/ 1951 1951 1951 1951 1951 1950 1951 1949 1949 1987 1950 1965 1965 1950 1950 1957 1995 1995 1949 1956 1956 1947 1980 1980 1993 1956 1949 1949 1953 1956/];
$Dailydata{highestTd}{October} = [qw/ 1977 1948 1952 1950 1986 1951 1951 1956 1962 1962 1962 1962 1950 1991 1954 1948 1947 1947 1947 1988 1949 1949 1951 1947 1947 1947 1950 1947 1950 1950 1947/];
$Dailydata{highestTd}{November} = [qw/ 1948 1950 1950 1973 1947 1963 1947 1969 1988 1969 1988 1988 1955 1978 1951 1951 1948 1957 1964 1988 1949 1963 1955 1973 1949 1981 1967 1949 1949 1949/];
$Dailydata{highestTd}{December} = [qw/ 1950 1950 1978 1970 1956 1951 1951 1956 1956 1971 1970 1949 1948 1948 1950 1990 1971 1995 1980 1949 1951 1948 1966 1955 1982 1955 1988 1971 1971 1971 1964/];
$Dailydata{lowestTd}{January} = [qw/ 1991 1979 1979 1947 1947 1972 1970 1976 1976 1962 1982 1982 1973 1964 1979 1972 1982 1982 1984 1984 1985 1985 1959 1963 1963 1978 1963 1948 1948 1966 1949/];
$Dailydata{lowestTd}{February} = [qw/ 1949 1951 1951 1989 1996 1989 1989 1971 1971 1973 1981 1981 1988 1958 1951 1951 1980 1980 1978 1978 1978 1964 1978 1965 1965 1960 1960 1962 1984/];
$Dailydata{lowestTd}{March} = [qw/ 1962 1980 1980 1965 1978 1989 1989 1989 1996 1996 1948 1948 1948 1975 1975 1947 1956 1960 1988 1965 1965 1955 1968 1952 1958 1955 1955 1955 1955 1975 1987/];
$Dailydata{lowestTd}{April} = [qw/ 1987 1970 1987 1987 1968 1994 1971 1996 1973 1973 1988 1988 1953 1980 1980 1961 1947 1983 1953 1953 1975 1993 1995 1995 1995 1978 1980 1973 1965 1996/];
$Dailydata{lowestTd}{May} = [qw/ 1996 1976 1993 1978 1954 1957 1992 1960 1984 1961 1981 1960 1960 1971 1973 1973 1999 1981 1986 1981 1947 1947 1967 1963 1979 1947 1961 1961 1961 1984 1984/];
$Dailydata{lowestTd}{June} = [qw/ 1964 1948 1970 1978 1969 1950 1969 1996 1996 1955 1955 1955 1979 1955 1956 1989 1989 1989 1989 1955 1976 1961 1955 1955 1974 1974 1974 1974 1985 1985/];
$Dailydata{lowestTd}{July} = [qw/ 1985 1985 1968 1985 1947 1968 1972 1985 1987 1947 1947 1955 1975 1990 1967 1967 1967 1974 1968 1947 1989 1970 1970 1947 1947 1959 1947 1985 1994 1994 1978/];
$Dailydata{lowestTd}{August} = [qw/ 1984 1971 1949 1949 1949 1971 1961 1957 1989 1989 1989 1965 1967 1967 1972 1963 1992 1992 1967 1976 1950 1956 1949 1949 1961 1966 1961 1968 1968 1992 1950/];
$Dailydata{lowestTd}{September} = [qw/ 1950 1950 1954 1952 1974 1974 1974 1950 1950 1988 1968 1959 1969 1959 1989 1979 1961 1981 1981 1981 1971 1983 1983 1994 1989 1989 1991 1967 1967 1967/];
$Dailydata{lowestTd}{October} = [qw/ 1984 1984 1961 1961 1975 1964 1964 1952 1952 1976 1990 1946 1977 1977 1969 1961 1974 1948 1989 1976 1976 1976 1996 1982 1982 1980 1957 1957 1993 1993 1993/];
$Dailydata{lowestTd}{November} = [qw/ 1993 1966 1951 1991 1950 1951 1959 1959 1991 1956 1950 1950 1975 1959 1969 1970 1970 1959 1959 1969 1969 1981 1975 1970 1950 1979 1993 1993 1976 1976/];
$Dailydata{lowestTd}{December} = [qw/ 1976 1979 1974 1990 1990 1950 1950 1950 1978 1978 1978 1957 1989 1989 1985 1989 1989 1979 1996 1996 1973 1989 1989 1989 1983 1983 1983 1961 1983 1983 1983/];

my @len = qw/30 27 30 29 30 29 30 30 29 30 29 30/; # month lengths
my @month = qw/ January February March April May June July August September October November December/;

for (my $i=0; $i<12; $i++) {
	for (my $j=0; $j<=$len[$i]; $j++) {
		$Dailydata{afternoon_humidity}{$month[$i]}->[$j] = getavg('afternoon_humidity', $i+1, $j+1);
		$Dailydata{morning_humidity}{$month[$i]}->[$j] = getavg('morning_humidity', $i+1, $j+1);
		$Dailydata{precip}{$month[$i]}->[$j] = getfrac('precip', $i+1, $j+1);
		$Dailydata{wind_speed}{$month[$i]}->[$j] = getavg('wind_speed', $i+1, $j+1);
	}
}


#-------------------------------------------------------------#
#	return weighted average based on day of month.
#	note that the input monthly averages are assumed
#	to be posted in the middle of each month
#-------------------------------------------------------------#
sub getavg {
	my $item = shift;
	my $mon = shift;
	my $day = shift;

	my $value;

	if (!defined $data{$item}) {return -999;}
	
	if ($day < $len[$mon-1]/2) {
		$value = $data{$item}->[($mon-2)%12] + 
		         ($data{$item}->[$mon-1] - $data{$item}->[($mon-2)%12])*
				 ($len[($mon-2)%12]/2 + $day)/
				 ($len[($mon-2)%12]/2 + $len[$mon-1]/2);
	}
	else {
		$value = $data{$item}->[$mon-1] + 
		         ($data{$item}->[($mon)%12] - $data{$item}->[$mon-1])*
				 ($day - $len[$mon-1]/2)/
				 ($len[$mon%12]/2 + $len[$mon-1]/2);
	}
	
	return sprintf("%6.2f",$value);
}

#-------------------------------------------------------------#
#	Return fraction of a monthly total (rainfall, for example)
#-------------------------------------------------------------#
sub getfrac {
	my $item = shift;
	my $month = shift;
	my $day = shift;

	my $value;

	if (!defined $data{$item}) {return -999;}
	
	$value = $data{$item}->[$month-1] / $len[$month-1]; 
	
	return sprintf("%6.2f",$value);
}

#-------------------------------------------------------------#
#	Just return the monthly value (highest recorded T, for example)
#-------------------------------------------------------------#
sub getvalue {
	my $item = shift;
	my $month = shift;
	my $day = shift;

	my $value;

	if (!defined $data{$item}) {return -999;}
	
	$value = $data{$item}->[$month-1] ; 
	
	return sprintf("%6.2f",$value);
}

#-------------------------------------------------------------#
#	Return array of values by requested increment
#	For greater than daily, take a window of size increment/2
#	forward from the current date, and find the average or
#	extremum, and return that value. That means that the values
#	returned are centered on the start date.
#	For increment = monthly, round off to the nearest month.
#	beg and end are supplied as mm/dd/yyyy
#-------------------------------------------------------------#
sub getarray {
	my $item = shift;
	my $beg = shift;
	my $end = shift;
	my $increment = shift; # daily, weekly, monthly, minutes, hourly
	my $avgminmax = shift; # avg, min, max, sum for weekly/monthly

	my @value;

	if (!defined $data{$item}) {return -999;}

	my ($m1, $d1, $y1) = split(/\//,$beg);
	my ($m2, $d2, $y2) = split(/\//,$end);

		# adjust begin date so that intervals will be equal.

	my $deltadays = Delta_Days($y1, $m1, $d1, $y2, $m2, $d2);
	if ($increment eq 'weekly' && $deltadays%7>0) {
		($y1, $m1, $d1 ) = Add_Delta_Days($y1, $m1, $d1, 7-$deltadays%7);
	}


	my $frac = 1;
	if ($avgminmax eq "frac" && $increment eq 'minutes') { $frac = 6*24;}
	if ($avgminmax eq "frac" && $increment eq 'hourly') { $frac = 24;}

	if ($increment eq 'daily') {
		for (my $i=0; $i<=Delta_Days($y1,$m1,$d1,$y2,$m2,$d2); $i++) {
			my ($y,$m,$d) = Add_Delta_Days($y1,$m1,$d1, $i);
			push @value, $Dailydata{$item}{$month[$m-1]}->[$d-1];
		}
	}
	elsif ($increment eq 'minutes' || $increment eq 'hourly') {
		my $ninc = 24; $ninc*=6 if $increment eq 'minutes';
		for (my $i=0; $i<=Delta_Days($y1,$m1,$d1,$y2,$m2,$d2); $i++) {
			my ($y,$m,$d) = Add_Delta_Days($y1,$m1,$d1, $i);
			my ($yp,$mp,$dp) = Add_Delta_Days($y1,$m1,$d1, $i-1);
			my ($yn,$mn,$dn) = Add_Delta_Days($y1,$m1,$d1, $i+1);
			my $prev = $Dailydata{$item}{$month[$mp-1]}->[$dp-1]/$frac;
			my $now = $Dailydata{$item}{$month[$m-1]}->[$d-1]/$frac;
			my $next = $Dailydata{$item}{$month[$mn-1]}->[$dn-1]/$frac;
			for (my $j=0; $j<$ninc/2; $j++) {
				push @value, ($j+$ninc/2)*($now-$prev)/$ninc +$prev;
			}
			push @value, $now;
			for (my $j=1; $j<=$ninc/2; $j++) {
				push @value, ($j)*($next-$now)/$ninc +$now;
			}
		}
	}
	elsif ($increment eq 'weekly') {
		for (my $i=0; $i<Delta_Days($y1,$m1,$d1,$y2,$m2,$d2); $i+=7) {
			my ($sum, $min, $max) = (0,999,-999);
			for (my $j=-3; $j<=3; $j++) {
				my ($y,$m,$d) = Add_Delta_Days($y1,$m1,$d1, $i+$j);
				my $v = $Dailydata{$item}{$month[$m-1]}->[$d-1];
				if (!defined $v) {print "$y,$m,$d $item\n";}
				$sum += $v;
				$min = $min<$v ? $min : $v;
				$max = $max>$v ? $max : $v;
			}
			push @value, sprintf("%5.1f",$sum/7) if $avgminmax eq 'avg';
			push @value, sprintf("%5.1f",$sum) if $avgminmax eq 'sum';
			push @value, sprintf("%3d",$min)   if $avgminmax eq 'min';
			push @value, sprintf("%3d",$max)   if $avgminmax eq 'max';
		}
	}
	elsif ($increment eq 'monthly') {
	}
	else {return -999;}
	
	
	return @value;
}

1;
