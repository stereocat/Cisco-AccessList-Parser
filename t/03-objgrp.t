#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use Parse::Eyapp;
use Cisco::AccessList::Parser;

plan( tests => 3 );
my $p = Cisco::AccessList::Parser->new();

my $data;

$data = << 'EOD';
object-group network SMTP_Server
 description ISP SMTP server
 host 192.168.0.2
 192.168.1.0 /24
 192.168.2.0 0.0.0.128
 group-object other_network
 host 172.16.2.3
 range 192.168.3.2 192.168.3.200
!
EOD
cmp_ok( $p->parse( 'input' => $data ),
    '==', 1, "single network object-group" );

$data = << 'EOD';
object-group service Web_Service
 description web service
 icmp echo
 tcp smtp
 tcp telnet
 tcp source range 1 65535
 udp domain
 tcp-udp range 2000 2005
 group-object other-list
EOD
cmp_ok( $p->parse( 'input' => $data ),
    '==', 1, "single service object-group" );

$data = << 'EOD';
object-group network SMTP_Server
 description ISP SMTP server
 host 192.168.0.2
 192.168.1.0 /24
 192.168.2.0 0.0.0.128
 group-object other_network
 host 172.16.2.3
 range 192.168.3.2 192.168.3.200
!
object-group network Group2
 192.168.1.0 /24
 host 172.16.2.3
 range 192.168.3.2 192.168.3.200
!
object-group service Service_1
 tcp source range 1 65535
 udp domain
 tcp-udp range 2000 2005
 group-object other-list
object-group service Service_2
 udp source gt 1024
 tcp-udp source range 2000 2005
 group-object other-list
EOD
cmp_ok( $p->parse( 'input' => $data ),
    '==', 4, "multiple service/network object-gropu mix" );

