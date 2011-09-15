use strict;
use warnings;
use Test::More;
use Parse::Eyapp;

plan (tests => 4);

use_ok( 'Parse::Eyapp' );
use_ok( 'Cisco::AccessList::Parser' );
diag( "Testing Cisco::AccessList::Parser $Cisco::AccessList::Parser::VERSION" );

my $p = Cisco::AccessList::Parser->new();

can_ok($p, "is_acl_accepted");
can_ok($p, "set_yydata_input");

