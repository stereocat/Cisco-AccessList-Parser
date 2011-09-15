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
    print "? ";
    while (<>) {
        last if m{^q(?:uit)?};
        $aclparser->set_yydata_input($_);
        parse_run($aclparser);
        $aclparser->set_yydata_input($_);
        $aclparser->lex_check();
        print "\n? ";
    }
}

sub parse_run {
    my $aclparser = shift;
    my $t;
    my $debug = 0x1F;
    $t = $aclparser->is_acl_accepted($debug);
    print $t, "\n";
}

line_by_line_test();
