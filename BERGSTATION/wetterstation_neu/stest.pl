#!/usr/bin/perl
use IO::Socket::INET;
use LWP::Simple;

# flush after every write
$| = 1;
my ($socket,$client_socket);
my ($peeraddress,$peerport);
# creating object interface of IO::Socket::INET modules which internally does
# socket creation, binding and listening at the specified port address.
$socket = new IO::Socket::INET (
LocalHost => '192.168.1.13',
LocalPort => '7977',
Proto => 'tcp',
Listen => 5,
Reuse => 1
    ) or die "ERROR in Socket Creation : $!\n";

print "SERVER Waiting for client connection on port 7977";

while(1)
{
# waiting for new client connection.
    $client_socket = $socket->accept();

# get the host and port number of newly connected client.
    $peer_address = $client_socket->peerhost();
    $peer_port = $client_socket->peerport();

    print "Accepted New Client Connection From : $peeraddress, $peerport\n";

# write operation on the newly accepted client.
#    $data = "DATA from Server";
#    print $client_socket "$data\n";

# we can also send the data through IO::Socket::INET module,
# $client_socket->send($data);

# read operation on the newly accepted client
    $data = <$client_socket>;
# we can also read from socket through recv()  in IO::Socket::INET
# $client_socket->recv($data,1024);
    print "Received from Client:\n $data\n\n";
$data =~ s/[^0-9\.\,:-]//igs;
print $data . "\n";
($xtime,$xdate,$xte,$xpr,$xhu,$xwm,$xws,$xwc,$xwd) = split(",",$data);
print "datetime:      $xdate $xtime\n";
print "temperature:   $xte\n";
print "pressure:      $xpr\n";
print "humidity:      $xhu\n";
print "windspeed:     $xws\n";
print "windmax:       $xwm\n";
print "winddirection: $xwd\n";
print "windchill:     $xwc\n";

$content = get("http://localhost:81/wetterstation/insert2.php?wd=$xwd&ws=$xws&te=$xte&pr=$xpr&ms=$xwm&hu=$xhu&wc=$xwc");
$content = get("http://para:geier\@www.lenkungsgruppe.de/v3/wetterstation/insert2.php?wd=$xwd&ws=$xws&te=$xte&pr=$xpr&ms=$xwm&hu=$xhu&wc=$xwc");
$content = get("http://wetter:merkur11\@www.gsvbaden.de/_extphp/wetterstation/insert/insert2.php?wd=$xwd&ws=$xws&te=$xte&pr=$xpr&ms=$xwm&hu=$xhu&wc=$xwc");

print $content;
}


$socket->close();
