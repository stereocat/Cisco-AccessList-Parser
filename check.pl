# -*- cperl -*-

use lib qw(.);
use strict;
use warnings;

use Parse::Eyapp;

use Data::Dumper;
use Cisco::AccessList::Parser;

#sub TERMINAL::info { $_[0]{attr} }

sub line_by_line_test {
    my $aclparser = Cisco::AccessList::Parser->new();
    my $debug = 0x1F;
    print "? ";
    while (<>) {
        last if m{^q(?:uit)?};

        my $t;
        $t = $aclparser->parse('debug' => $debug, 'input' => $_);
        print $t, "\n";

        $aclparser->lex_check('input' => $_);
        print "\n? ";
    }
}

line_by_line_test();
