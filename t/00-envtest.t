use strict;
use warnings;
use Test::More;
use Parse::Eyapp;

plan (tests => 3);

use_ok("AclParser");

my $p = AclParser->new();

can_ok($p, "is_acl_accepted");
can_ok($p, "set_yydata_input");

