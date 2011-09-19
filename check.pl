# -*- cperl -*-

use lib qw(.);
use strict;
use warnings;

use Parse::Eyapp;

use Data::Dumper;
use Cisco::AccessList::Parser;

#sub TERMINAL::info { $_[0]{attr} }

my $aclparser = Cisco::AccessList::Parser->new();
my $debug     = 0x1F;
print "? ";
while (<>) {
    last if m{^q(?:uit)?};

    my ($acl, $objgrp) = $aclparser->parse( 'debug' => $debug, 'input' => $_ );
    print Dumper $acl, $objgrp;

    $aclparser->lex_check( 'input' => $_ );
    print "\n? ";
}
