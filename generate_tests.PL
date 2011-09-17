#!/usr/bin/perl

use strict;
use warnings;

# test script
# generate test files from t/*.conf test configurations

print "# Generate Test Scripts\n";
my $generate_cmd = "perl t/testcase-generator.pl t/*.conf";
system($generate_cmd)
    and die "Could not run: $generate_cmd";
