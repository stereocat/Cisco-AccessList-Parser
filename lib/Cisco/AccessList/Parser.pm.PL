#!/usr/bin/perl

# Generate Parse.pm from Parse.eyp
# see also: 'code' action in Module::Build

use strict;
use warnings;

my $grammer_file = $0;
$grammer_file =~ s/\.pm\.PL/.eyp/g;
my $module_file = $0;
$module_file =~ s/\.PL//g;

my $generate_cmd = join( q{ },
    "eyapp",
    "-m 'Cisco::AccessList::Parser'",
    "-o $module_file",
    "-v $grammer_file" );

print "# Generate $module_file from $grammer_file\n";
print "# $generate_cmd\n";

system($generate_cmd)
    and die "Could not run: $generate_cmd";
