#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use Parse::Eyapp;
use Cisco::AccessList::Parser;

plan( tests => 1 );
my $p = Cisco::AccessList::Parser->new();

my $data;
my ($acl, $objgrp);

$data = << 'EOD';
access-list 1 permit 192.168.0.0 0.0.255.255
access-list 1 deny   any log
access-list 9 permit 192.168.0.0 0.0.255.255
access-list 10 deny   any log
access-list 99 permit 192.168.0.0 0.0.255.255
access-list 99 deny   any log
!
access-list 100 remark DNS Exempt
access-list 100 deny   udp 122.219.206.8 0.0.0.7 any eq domain
access-list 100 deny   tcp 122.219.206.8 0.0.0.7 any eq domain
access-list 100 remark NTP
access-list 100 permit tcp any host 210.197.74.200
access-list 100 permit udp any eq ntp any eq ntp
access-list 100 deny   ip any any log
access-list 110 remark SPLIT_VPN
access-list 110 permit ip 192.168.0.0 0.0.255.255 any
access-list 120 permit ip 192.168.0.0 0.0.255.255 any
access-list 120 permit ip any any log
!
object-group network Group2
 192.168.1.0 /24
 host 172.16.2.3
 range 192.168.3.2 192.168.3.200
!
object-group service Web_Service
 description web service
 icmp echo
 tcp smtp
 tcp telnet
 tcp source range 1 65535
 udp domain
 tcp-udp range 2000 2005
 group-object other-list
!
ip access-list standard remote-ipv4
 permit 192.168.0.0 0.0.255.255
 deny   any log
!
ip access-list standard test-acl
 permit 192.168.0.0 0.0.255.255
 permit 192.168.2.0 0.0.255.255
 permit host 192.168.4.5
 deny   any log
!
ip access-list extended FA0-IN
 deny   ip 169.254.0.0 0.0.255.255 any log
 deny   ip 224.0.0.0 31.255.255.255 any log
 permit object-group Web_Service any object-group Group2
!
ip access-list extended FA0-OUT
 deny   ip any 10.0.0.0 0.255.255.255 log
 permit icmp any any
 permit tcp any object-group Group2
 permit ip any any reflect iptraffic timeout 300
 deny   ip any any log
!
EOD
( $acl, $objgrp ) = $p->parse( 'input' => $data );
cmp_ok( (keys(%$acl) + keys(%$objgrp)), '==', 13, "acl mix" );

