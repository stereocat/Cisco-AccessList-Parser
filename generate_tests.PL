#!/usr/bin/perl
use strict;
use warnings;
use YAML;
use Path::Class;

sub generate_case {
    my $field_data = shift;
    my $fieldseq   = shift;

    my $test_field = shift @$fieldseq;

    if ( !defined($test_field) ) {
        return [ { data => "", valid => "1", todo => undef } ];
    }
    if ( !exists( $field_data->{$test_field} ) ) {
        die "Unknown field name: $test_field";
    }

    my $later_test_case = generate_case( $field_data, $fieldseq );

    my $result = [];
    foreach my $field ( @{ $field_data->{$test_field} } ) {
        my $curr_data  = $field->{data};
        my $curr_valid = $field->{valid};
        my $curr_todo  = $field->{todo};

        foreach my $later_field (@$later_test_case) {

            my $later_data  = $later_field->{data};
            my $later_valid = $later_field->{valid};
            my $later_todo  = $later_field->{todo};

            my $data = join( q{ }, $curr_data, $later_data );
            $data =~ s/\s+$//;
            my $valid = $curr_valid * $later_valid;
            my $todo = defined($curr_todo) ? $curr_todo : $later_todo;

            push( @$result,
                { data => $data, valid => $valid, todo => $todo } );
        }
    }
    return $result;
}
############################################################

sub generate_test_script {
    my $code                 = shift;
    my $field_data_dir       = shift;
    my $test_name            = shift;
    my $generate_test_script = shift;
    my $test_script_file     = file( $field_data_dir, $test_name . '.t' );
    open my $tsfh, ">", $test_script_file
        or die "Cannot open $test_script_file: $!";

    print $tsfh $code;

    foreach my $testcase (@$generate_test_script) {
        my $data   = $testcase->{'data'};
        my $todo   = defined( $testcase->{'todo'} ) ? $testcase->{'todo'} : 0;
        my $valid  = $testcase->{'valid'};
        my $record = <<"EOL";
===
--- data: $data
--- todo: $todo
--- valid: $valid
EOL
        print $tsfh $record;
    }
    close $tsfh;
    print "# Generate Test Script: $test_script_file\n";
}

############################################################

# read __DATA__ token; test running program
my $test_runner_code = do { local $/; <DATA> };

foreach my $test_conf_file (<t/*.conf>) {
    my $test_conf_list = YAML::LoadFile($test_conf_file)
        or die "Cannot Load Test Conf File: $test_conf_file";
    print "# Load Test Conf File: $test_conf_file\n";

    foreach my $test_case (@$test_conf_list) {

        # data check
        if ( !exists( $test_case->{testname} ) ) {
            die "test case name: not specified in conf file: $test_conf_list";
        }
        if ( !exists( $test_case->{casedata} ) ) {
            die "data file: not specified in conf file: $test_conf_file";
        }
        if ( !exists( $test_case->{fieldseq} ) ) {
            die "fieldseq-data: not contained in conf file: $test_conf_file";
        }

        # data construction sequence data list
        my $fieldseq = $test_case->{fieldseq};

        # load data file (input)
        my $field_data_file = $test_case->{casedata};
        my $field_data_dir  = file($test_conf_file)->parent;
        my $field_data
            = YAML::LoadFile( file( $field_data_dir, $field_data_file ) );

        # generated test case
        my $generated_test_case = generate_case( $field_data, $fieldseq );

        # save generated test case to dat file
        generate_test_script(
            $test_runner_code,      $field_data_dir,
            $test_case->{testname}, $generated_test_case
        );
    }
}

__DATA__
#!/usr/bin/perl

use strict;
use warnings;
use Test::Base;
use Cisco::AccessList::Parser;

my $p = Cisco::AccessList::Parser->new();

plan tests => 1 * blocks;

run {
    my $block = shift;
    my $data  = $block->data();
    my $valid = $block->valid();
    my $todo  = $block->todo();
    my ($acl, $objgrp);

    ( $acl, $objgrp ) = $p->parse( 'input' => $data );

    if ( !( defined($todo) && length($todo) > 0 ) ) {
        is( keys(%$acl) + keys(%$objgrp), $valid, $data );
    }
    else {
      TODO: {
        local $TODO = $todo;
        is( keys(%$acl) + keys(%$objgrp), $valid, $data );
      }
    }
};
__DATA__
