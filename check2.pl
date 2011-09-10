# -*- cperl -*-

use lib qw(.);
use strict;
use warnings;

use Parse::Eyapp;

use Data::Dumper;
use AclParser;

#sub TERMINAL::info { $_[0]{attr} }

sub multi_line_test {
    my $input = << "EOACL";
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
 remark permit USEN DHCP
 permit udp any eq bootps any eq bootpc
 remark home web server
 permit tcp any any eq 8000
 remark share
 permit tcp any any eq 25010
 remark permit any from inside to outside
 evaluate iptraffic
 permit tcp any any established
 permit icmp any any
 deny   ip any any log
EOACL

    my $multiple_std_acl = << 'EOACL';
access-list 1 permit 192.168.0.0 0.0.255.255
access-list 1 deny   any log
access-list 9 permit 192.168.0.0 0.0.255.255
access-list 10 deny   any log
access-list 99 permit 192.168.0.0 0.0.255.255
access-list 99 deny   any log
EOACL

    my $multiple_ext_acl = << 'EOACL';
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
access-list 120 permit tcp any any log
EOACL


    my $multiple_std_ext_acl_mix = << 'EOACL';
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
access-lst 110 permit hoge
access-list 110 deny ip any any log
access-list 120 permit ip 192.168.0.0 0.0.255.255 any
access-list 120 permit tcp any any log
EOACL

    my $multiple_named_std_acl = << 'EOACL';
ip access-list standard remote-ipv4
 permit 192.168.0.0 0.0.255.255
 remark deny all
 deny   any log
!
ip access-list standard test-acl
 permit 192.168.0.0 0.0.255.255
 permit 192.168.2.0 0.0.255.255
 permit host 192.168.4.5
 deny   any log
!
EOACL

    my $multiple_named_ext_acl = << 'EOACL';
!
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
EOACL


    my $multiple_named_ext_std_acl_mix = << 'EOACL';
ip access-list extended FA0-IN
 deny   ip 169.254.0.0 0.0.255.255 any log
 deny   ip 224.0.0.0 31.255.255.255 any log
 deny   tcp any any eq 135 log
!
ip acess-list extended FA0-OUT
 deny   ip any 10.0.0.0 0.255.255.255 log
 permit icmp any any
 permit ip any any reflect iptraffic timeout 300
 deny   ip any any log
!
ip access-list extended FA0-IN
 deny   ip 169.254.0.0 0.0.255.255 any log
 deny   ip 224.0.0.0 31.255.255.255 any log
 deny   tcp any any eq 135 log
!
ip acess-list extended FA0-OUT
 deny   ip any 10.0.0.0 0.255.255.255 log
 permit icmp any any
 permit ip any any reflect iptraffic timeout 300
 deny   ip any any log
!
EOACL



    
    my $input2 = << 'EOACL';
ip access-list standard remote-ipv4
 permit 192.168.0.0 0.0.255.255
 deny   any log
!
ip access-list extended FA0-IN
 deny   ip 169.254.0.0 0.0.255.255 any log
 deny   ip 224.0.0.0 31.255.255.255 any log
 deny   tcp any any eq 135 log
!
ip acess-list extended FA0-OUT
 deny   ip any 10.0.0.0 0.255.255.255 log
 permit icmp any any
 permit ip any any reflect iptraffic timeout 300
 deny   ip any any log
!
EOACL

    my $input3 = << 'EOACL';
access-list 1 permit 192.168.0.0 0.0.255.255
access-list 1 deny   any log
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
EOACL

    my $input5 = << 'EOACL';
access-list 130 deny   ip any any log
access-list 130 remark SPLIT_VPN
access-list 130 permit ip 192.168.0.0 0.0.255.255 any
access-list 120 remark SPLIT_VPN
access-list 120 permit udp any eq 0 any eq 0
access-list 100 permit udp any eq 0 any eq 0
access-list 100 deny   ip any any log
access-list 100 permit ip 192.168.0.0 0.0.255.255 any
EOACL

    my $input6 = << 'EOACL';
ip access-list standard remote-ipv4
 deny host 192.168.0.33 log
 permit 192.168.0.0 0.0.255.255
 deny   any hoge log
EOACL

    my $input7 = << "EOACL";
ip access-list extended FA0-IN
 deny   tcp any any eq 1433 log
 remark ip vpn
 permit udp any eq domain 122.219.206.8 0.0.0.7
 deny   ipinip any any log
 deny   ip any any log
EOACL

    my $input8 = << "EOACL";
ip access-list standard remote-ipv4
 deny host 192.168.0.33 log
 permit 192.168.0.0 0.0.255.255
 deny   any any log
EOACL

    my $input9 = << "EOACL";
ip access-list standard remote-ipv4
 deny host 192.168.0.33 log
 permit 192.168.0.0 0.0.255.255
 deny   any log
EOACL

    my $test_data = $input9;
    my $aclparser;
    $aclparser = AclParser->new();
    $aclparser->set_yydata_input($test_data);
    parse_run($aclparser);
    print "==================\n";
    $aclparser = AclParser->new();
    $aclparser->set_yydata_input($test_data);
    $aclparser->lex_check();
}

sub parse_run {
    my $aclparser = shift;
    my $t;
    my $debug = 0x1F;
    $t = $aclparser->is_acl_accepted($debug);
    print "RESULT: ", $t, "\n";
}

multi_line_test();

