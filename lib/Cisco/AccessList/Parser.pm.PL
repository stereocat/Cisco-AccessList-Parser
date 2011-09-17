#!/usr/bin/perl

# Generate Parse.pm from Parse.eyp
# see also: 'code' action in Module::Build

use strict;
use warnings;

my $grammer_file = $0;
$grammer_file =~ s/\.pm\.PL/.eyp/g;
my $generate_cmd = "eyapp -m 'Cisco::AccessList::Parser' -v $grammer_file";
print "# $generate_cmd\n";
system($generate_cmd)
    and die "Could not run: $generate_cmd";
