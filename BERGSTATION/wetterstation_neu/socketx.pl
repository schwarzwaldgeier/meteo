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
$data = "!Z6\n";
#print $client_socket $data";

# we can also send the data through IO::Socket::INET module,
$client_socket->send($data);

# read operation on the newly accepted client
    $data = <$client_socket>;
# we can also read from socket through recv()  in IO::Socket::INET
# $client_socket->recv($data,1024);
    print "Received from Client:\n $data\n\n";
}


$socket->close();
