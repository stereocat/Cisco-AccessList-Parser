#!/usr/bin/perl
use strict;
use warnings;
use YAML;
use Path::Class;
use Data::Dumper;

sub generate_case {
    my $field_data = shift;
    my $fieldseq   = shift;

    my $test_field = shift @$fieldseq;

    if ( !defined($test_field) ) {
        return [
            {   data  => "",
                valid => "1",
                todo  => undef
            }
        ];
    }
    if ( !exists( $field_data->{$test_field} ) ) {
        die "Unknown field name: $test_field";
    }

    # data by later fields was generated recursively.
    my $later_test_case = generate_case( $field_data, $fieldseq );

    my $result = [];
    foreach my $field ( @{ $field_data->{$test_field} } ) {
        my $curr_data  = $field->{data};
        my $curr_valid = $field->{valid};
        my $curr_todo  = $field->{todo};
        my $curr_expected_msg
            = exists( $field->{expected_msg} )
            ? $field->{expected_msg}
            : undef;
        my $curr_struct
            = exists( $field->{struct} ) ? $field->{struct} : undef;

        foreach my $later_field (@$later_test_case) {

            my $later_data  = $later_field->{data};
            my $later_valid = $later_field->{valid};
            my $later_todo  = $later_field->{todo};
            my $later_expected_msg
                = exists( $later_field->{expected_msg} )
                ? $later_field->{expected_msg}
                : undef;
            my $later_struct
                = exists( $later_field->{struct} )
                ? $later_field->{struct}
                : undef;

            my $data = join( q{ }, $curr_data, $later_data );
            $data =~ s/\s+$//;
            my $valid = $curr_valid * $later_valid;
            my $todo = defined($curr_todo) ? $curr_todo : $later_todo;

            # expected message
            my $expected_msg = [];
            push @$expected_msg, $curr_expected_msg
                if ( defined($curr_expected_msg) );
            push @$expected_msg, @$later_expected_msg
                if ( defined($later_expected_msg) );

            # struct

            # print "# valid: $valid, ";
            # print "curr: $test_field / $curr_data, data: $data\n";
            # print "# curr_struct: $curr_struct\n";
            # print "# later_struct: ", Dumper $later_struct, "\n";
            my $struct = [];
            if ( defined($curr_struct) && $curr_struct =~ /##entry##/ ) {
                my $later_struct_str
                    = defined($later_struct)
                    ? join( q{, }, @$later_struct )
                    : q{};
                my $curr_struct_str = $curr_struct;
                $curr_struct_str =~ s/##entry##/$later_struct_str/g;
                push @$struct, $curr_struct_str;
                # print "## later: ", $later_struct_str, "\n";
                # print "## curr :",  $curr_struct_str,  "\n";
            }
            elsif ( defined($curr_struct) && $curr_struct =~ /##right##/ ) {
                my $curr_struct_str = $curr_struct;
                my $right_str = q{};

                # print "## later_struct: ", Dumper $later_struct;
                $right_str = shift @$later_struct
                    if(defined($later_struct) && @$later_struct > 0);
                $curr_struct_str =~ s/##right##/$right_str/g;

                # print "## curr :", $curr_struct_str, "\n";
                # print "## right:", $right_str, "\n";
                push @$struct, $curr_struct_str;
                push @$struct, @$later_struct
                    if ( defined($later_struct) );

                ## the data will used for pattern generation
                ## by other current fields. DO NOT delete.
                unshift @$later_struct, $right_str;
            }
            else {
                push @$struct, $curr_struct
                    if ( defined($curr_struct) );
                push @$struct, @$later_struct
                    if ( defined($later_struct) );
            }

            # test data construction
            push(
                @$result,
                {   data         => $data,
                    valid        => $valid,
                    todo         => $todo,
                    expected_msg => $expected_msg,
                    struct       => $struct
                }
            );
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
        my $data  = $testcase->{'data'};
        my $todo  = defined( $testcase->{'todo'} ) ? $testcase->{'todo'} : "";
        my $valid = $testcase->{'valid'};
        my $expected_msg = join( q{,}, @{ $testcase->{'expected_msg'} } );
        my $struct = $valid>0 ? join( q{}, @{ $testcase->{'struct'} } ) : "";
        # print Dumper $struct;

        my $record = <<"EOL";
===
--- data: $data
--- todo: $todo
--- valid: $valid
--- struct: $struct
--- expected_msg: [$expected_msg]
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

############################################################
#
# This program generate test-case recursively.
#
# Fieldseq: A  B  C
#           A1 B1 C1
#           A2 B2
#
# 1st: C-[]
#   => [C]
# 2nd: B1-[C], B2-[C]
#   => [B1-C, B2-C]
# 3rd: A1-[B1-C, B2-C], A2-[B1-C, B2-C]
#   => [A1-B1-C, A1-B2-C, A2-B1-C, A2-B2-C]
#
############################################################

__DATA__
#!/usr/bin/perl

use strict;
use warnings;
use Test::Base;
use Test::Warn;
use YAML::XS;
use Data::Dumper;
use Cisco::AccessList::Parser;

my $p = Cisco::AccessList::Parser->new();

plan tests => 1 * blocks;

sub check_acl {
    my $p = shift;
    my $block = shift;

    my $data  = $block->data();
    my $valid = $block->valid();
    my $todo  = $block->todo();


    my ($acl, $objgrp);

    if($valid > 0) {
        my $str_hashref = YAML::XS::Load( $block->struct() );

        ( $acl, $objgrp ) = $p->parse( 'input' => $data );
        #is( keys(%$acl) + keys(%$objgrp), $valid, $data );

        my $got;
        if ( defined($acl) ) {
            $got = $acl;
        }
        else {
            $got = $objgrp;
        }

        is_deeply( $got, $str_hashref, $data );
        # print "## str: ", $block->struct(), "\n";
        # print "## str: ", Dumper $str_hashref, "\n";
        # print "## str-p: ", Dumper $acl, "\n";
    }
    else {
        # print "## msg: ", $block->expected_msg(), "\n";
        my $msg_hashref = YAML::XS::Load( $block->expected_msg() );

        # If multiple error messages was generated,
        # this test only certify a messages at first of them.
        my $exist_err = shift @$msg_hashref;

        warnings_exist {
            ( $acl, $objgrp ) = $p->parse( 'input' => $data );
        } [$exist_err], $data;


    }
}

run {
    my $block = shift;
    my $data  = $block->data();
    my $valid = $block->valid();
    my $todo  = $block->todo();

    if ( !( defined($todo) && length($todo) > 0 ) ) {
        check_acl($p, $block);
    }
    else {
      TODO: {
        local $TODO = $todo;
        check_acl($p, $block);
      }
    }
};
__DATA__
