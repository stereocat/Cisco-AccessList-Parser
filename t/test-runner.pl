#!/usr/bin/perl

use strict;
use warnings;
use YAML::XS;
use Data::Dumper;
use Test::More;
use Parse::Eyapp;
use AclParser;

if ( !defined( $ARGV[0] ) ) {
    die "usage: $0 test-data.dat";
}
my $test_data_output_file = $ARGV[0];
my $test_case             = YAML::XS::LoadFile($test_data_output_file)
    or die "Cannot load $test_data_output_file";

my $test_count = @$test_case;
plan (tests => $test_count);
my $p = AclParser->new();

foreach my $test (@$test_case) {
    my $data  = $test->{data};
    my $valid = $test->{valid};
    my $todo  = $test->{todo};

    $p->set_yydata_input($data);

    if ( !( defined($todo) && length($todo) > 0 ) ) {
        cmp_ok($p->is_acl_accepted(), '==', $valid, $data);
    }
    else {
      TODO: {
            local $TODO = $todo;
            $p->set_yydata_input($data);
            cmp_ok($p->is_acl_accepted(), '==', $valid, $data);
        }
    }
}
