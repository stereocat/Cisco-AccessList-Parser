# -*- cperl -*-

use lib qw(.);
use strict;
use warnings;

use Parse::Eyapp;
use Test::More;
use Test::Warn;
use Data::Dumper;
use Cisco::AccessList::Parser;

#sub TERMINAL::info { $_[0]{attr} }

plan tests => 2;

my $input = << "EOACL";
access-list 100 permit 256 192.168.0.0 0.0.0.128 any
EOACL

my $aclparser = Cisco::AccessList::Parser->new();

my $data = $input;
my $debug     = 0;

my ( $acl, $objgrp );
warning_like {
    ( $acl, $objgrp ) = $aclparser->parse( 'input' => $data );
} [qr/WARNING: Protocol/, qr/WARNING: Syntax error/], $data;

warnings_exist {
    ( $acl, $objgrp ) = $aclparser->parse( 'input' => $data );
} qr/WARNING: Protocol/, $data;

# print "RESULT: ", ( keys(%$acl) + keys(%$objgrp) ), "\n";
# print "==================\n";
# $aclparser->lex_check( 'input' => $test_data );

__END__

access-list 100 permit 256 host 192.168.0.1 10.1.0.2
                       ~~~                           ~~~~~~~~~
複数箇所のエラー: 複数エラーの出力/テストをどうハンドリングするか

----------------------------------------
In state 40:
Stack: 0->'EXTACL'->12->'dynamic_spec'->27->'action'->69->'NUMBER'->40
Don't need token.
Reduce using rule 31 (ip_proto --> NUMBER): WARNING: Syntax error, near: >end-of-input<.
Expected one of these tokens: HOST IPV4_ADDR ANY
Back to state 69, then go to state 229.
----------------------------------------
In state 229:
Stack: 0->'EXTACL'->12->'dynamic_spec'->27->'action'->69->'ip_proto'->229
Need token. Got >HOST<
Shift and go to state 77.
----------------------------------------

数値チェックで yyerror がよばれているけど ip_proto は受理されてしまっている

    
