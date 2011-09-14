#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use Parse::Eyapp;
use Cisco::AccessList::Parser;

plan (tests => 6);
my $p = Cisco::AccessList::Parser->new();

my $data;

$data = << 'EOD';
access-list 1 permit 192.168.0.0 0.0.255.255
access-list 1 deny   any log
access-list 9 permit 192.168.0.0 0.0.255.255
access-list 10 deny   any log
access-list 99 permit 192.168.0.0 0.0.255.255
access-list 99 deny   any log
EOD
$p->set_yydata_input($data);
cmp_ok($p->is_acl_accepted(), '==', 4, "multiple std acl");

$data = << 'EOD';
access-list 100 remark DNS Exempt
access-list 100 deny   udp 122.219.206.8 0.0.0.7 any eq domain
access-list 100 deny   tcp 122.219.206.8 0.0.0.7 any eq domain
access-list 100 remark NTP
access-list 100 permit tcp any host 210.197.74.200
access-list 100 permit udp any eq ntp any eq ntp
access-list 100 remark 6to4
access-list 100 permit 41 any host 192.88.99.1
access-list 100 permit ip any host 192.88.99.1
access-list 100 remark others
access-list 100 permit tcp any eq 0 any eq 0
access-list 100 permit udp any eq 0 any eq 0
access-list 100 deny   ip any any log
access-list 110 remark SPLIT_VPN
access-list 110 permit ip 192.168.0.0 0.0.255.255 any
access-list 120 permit ip 192.168.0.0 0.0.255.255 any
access-list 120 permit ip any any log
EOD
$p->set_yydata_input($data);
cmp_ok($p->is_acl_accepted(), '==', 3, "multiple ext acl");

$data = << 'EOD';
access-list 1 permit 192.168.0.0 0.0.255.255
access-list 1 deny   any log
access-list 9 permit 192.168.0.0 0.0.255.255
access-list 10 deny   any log
access-list 99 permit 192.168.0.0 0.0.255.255
access-list 99 deny   any log
access-list 100 remark DNS Exempt
access-list 100 deny   udp 122.219.206.8 0.0.0.7 any eq domain
access-list 100 deny   tcp 122.219.206.8 0.0.0.7 any eq domain
access-list 100 remark NTP
access-list 100 permit tcp any host 210.197.74.200
access-list 100 permit udp any eq ntp any eq ntp
access-list 100 remark 6to4
access-list 100 permit 41 any host 192.88.99.1
access-list 100 permit ip any host 192.88.99.1
access-list 100 remark others
access-list 100 permit tcp any eq 0 any eq 0
access-list 100 permit udp any eq 0 any eq 0
access-list 100 deny   ip any any log
access-list 110 remark SPLIT_VPN
access-list 110 permit ip 192.168.0.0 0.0.255.255 any
access-list 120 permit ip 192.168.0.0 0.0.255.255 any
access-list 120 permit ip any any log
EOD
$p->set_yydata_input($data);
cmp_ok($p->is_acl_accepted(), '==', 7, "multiple ext/std acl mix");


$data = << 'EOD';
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
EOD
$p->set_yydata_input($data);
cmp_ok($p->is_acl_accepted(), '==', 2, "multiple named-std-acl");

$data = << 'EOD';
ip access-list extended FA0-IN
 deny   ip 169.254.0.0 0.0.255.255 any log
 deny   ip 224.0.0.0 31.255.255.255 any log
 deny   tcp any any eq 135 log
!
ip access-list extended FA0-OUT
 deny   ip any 10.0.0.0 0.255.255.255 log
 permit icmp any any
 permit ip any any reflect iptraffic timeout 300
 deny   ip any any log
!
EOD
$p->set_yydata_input($data);
cmp_ok($p->is_acl_accepted(), '==', 2, "multiple named-ext-acl");

$data = << 'EOD';
ip access-list extended FA0-IN
 deny   ip 169.254.0.0 0.0.255.255 any log
 deny   ip 224.0.0.0 31.255.255.255 any log
 deny   tcp any any eq 135 log
!
ip access-list extended FA0-OUT
 deny   ip any 10.0.0.0 0.255.255.255 log
 permit icmp any any
 permit ip any any reflect iptraffic timeout 300
 deny   ip any any log
!
ip access-list extended FA1-IN
 deny   ip 169.254.0.0 0.0.255.255 any log
 deny   ip 224.0.0.0 31.255.255.255 any log
 deny   tcp any any eq 135 log
!
ip access-list extended FA1-OUT
 deny   ip any 10.0.0.0 0.255.255.255 log
 permit icmp any any
 permit ip any any reflect iptraffic timeout 300
 deny   ip any any log
!
EOD
$p->set_yydata_input($data);
cmp_ok($p->is_acl_accepted(), '==', 4, "multiple named-ext/std-acl mix");

