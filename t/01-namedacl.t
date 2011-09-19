#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use Parse::Eyapp;
use Cisco::AccessList::Parser;

plan (tests => 6);
my $p = Cisco::AccessList::Parser->new();

my $data;
my ($acl, $objgrp);

$data = << 'EOD';
ip access-list extended FA0-IN
EOD
( $acl, $objgrp ) = $p->parse( 'input' => $data );
cmp_ok( keys(%$acl), '==', 1, "named-ext-acl: header only (implicit deny)" );

$data = << 'EOD';
ip access-list extended FA0-IN
 deny   ip 10.0.0.0 0.255.255.255 any log
 deny   ip 172.16.0.0 0.15.255.255 any log
 deny   ip 192.168.0.0 0.0.255.255 any log
 deny   ip 0.0.0.0 0.255.255.255 any log
 deny   ip 127.0.0.0 0.255.255.255 any log
 deny   ip 192.0.2.0 0.0.0.255 any log
 deny   ip 169.254.0.0 0.0.255.255 any log
 deny   ip 224.0.0.0 31.255.255.255 any log
 deny   tcp any any eq 135 log
 deny   udp any any eq 135 log
 deny   tcp any any range 137 139 log
 deny   udp any any range netbios-ns netbios-ss log
 deny   tcp any any eq 445 log
 deny   udp any any eq 445 log
 deny   tcp any any eq 6000 log
 deny   tcp any any eq 1433 log
 remark vpn
 permit udp any eq domain 122.219.206.8 0.0.0.7
 remark vpn
 permit esp any any
 permit tcp any any eq 50
 permit tcp any any eq 51
 permit udp any any eq isakmp
 permit udp any any eq 1701
 remark ntp
 permit udp host 210.188.224.14 eq ntp any
 permit udp host 61.122.112.135 eq ntp any
 remark 6to4
 permit ip 192.88.99.0 0.0.0.255 any
 permit 41 any any
 remark permit CARRIER DHCP
 permit udp any eq bootps any eq bootpc
 remark home web server
 permit tcp any any eq 8000
 remark permit any from inside to outside
 evaluate iptraffic
 permit tcp any any established
 permit icmp any any
 deny   ip any any log
!
EOD
( $acl, $objgrp ) = $p->parse( 'input' => $data );
cmp_ok( keys(%$acl), '==', 1, "Normal named-ext-acl" );


$data = << 'EOD';
ip acess-list extended FA0-OUT
 deny   ip any 10.0.0.0 0.255.255.255 log
 deny   ip any 172.16.0.0 0.15.255.255 log
 deny   ip any 192.168.0.0 0.0.255.255 log
 deny   ip any 0.0.0.0 0.255.255.255 log
 deny   ip any 127.0.0.0 0.255.255.255 log
 deny   ip any 192.0.2.0 0.0.0.255 log
 deny   ip any 169.254.0.0 0.0.255.255 log
 deny   ip any 224.0.0.0 31.255.255.255 log
 deny   tcp any any eq 135 log
 deny   udp any any eq 135 log
 deny   tcp any any range 137 139 log
 deny   udp any any range netbios-ns netbios-ss log
 deny   tcp any any eq 445 log
 deny   udp any any eq 445 log
 deny   tcp any eq 135 any log
 deny   udp any eq 135 any log
 deny   tcp any range 137 139 any log
 deny   udp any range netbios-ns netbios-ss any log
 deny   tcp any eq 445 any log
 deny   udp any eq 445 any log
 deny   tcp any any eq 6000 log
 deny   tcp any any eq 1433 log
 remark vpn
 permit udp any eq isakmp any
 remark permit to 6to4
 permit ip any 192.88.99.0 0.0.0.255
 permit 41 any 192.88.99.0 0.0.0.255
 remark permit any from inside to outside
 permit icmp any any
 permit ip any any reflect iptraffic timeout 300
 deny   ip any any log
EOD
( $acl, $objgrp ) = $p->parse( 'input' => $data );
cmp_ok( keys(%$acl), '==', 0, "named-ext-acl: header error");

$data = << 'EOD';
ip access-list standard remote-ipv4
EOD
( $acl, $objgrp ) = $p->parse( 'input' => $data );
cmp_ok( keys(%$acl), '==', 1, "named-std-acl: header only (implicit deny)");

$data = << 'EOD';
ip access-list standard remote-ipv4
 deny host 192.168.0.33 log
 permit 192.168.0.0 0.0.255.255
 deny   any log
EOD
( $acl, $objgrp ) = $p->parse( 'input' => $data );
cmp_ok( keys(%$acl), '==', 1, "normal named-std-acl");

$data = << 'EOD';
ip access-list standard remote-ipv4
 deny host 192.168.0.33 log
 permit 192.168.0.0 0.0.255.255
 deny   any any log
EOD
( $acl, $objgrp ) = $p->parse( 'input' => $data );
cmp_ok( keys(%$acl), '==', 0, "named-std-acl: body error");
