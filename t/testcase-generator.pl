#!/usr/bin/perl
use strict;
use warnings;
use YAML::XS;
use Data::Dumper;

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

    # print "\n\n** $test_field / goto recursive **\n";
    my $later_test_case = generate_case( $field_data, $fieldseq );

    # print "\n\n** $test_field / result of later fields case **\n";
    # print Dumper $later_test_case;

    my $result = [];
    foreach my $field ( @{ $field_data->{$test_field} } ) {
        my $curr_data  = $field->{data};
        my $curr_valid = $field->{valid};
        my $curr_todo  = $field->{todo};

        # print $curr_todo if defined $curr_todo;

        # print "\n*** $test_field concate ***\n";
        # print YAML::XS::Dump $field;

        foreach my $later_field (@$later_test_case) {

            # print "\n**** $test_field get later field ****\n";
            # print Dumper $later_field;

            my $later_data  = $later_field->{data};
            my $later_valid = $later_field->{valid};
            my $later_todo  = $later_field->{todo};

            my $data  = join( q{ }, $curr_data, $later_data );
            $data =~ s/\s+$//;
            my $valid = $curr_valid * $later_valid;
            my $todo  = defined($curr_todo) ? $curr_todo : $later_todo;

            push( @$result,
                { data => $data, valid => $valid, todo => $todo } );
        }
    }
    return $result;
}

############################################################

# read test-configuration file
if ( !defined( $ARGV[0] ) ) {
        die "usage: $0 testsetting.conf ";
}
my $test_conf_file = $ARGV[0];
my $test_conf      = YAML::XS::LoadFile($test_conf_file);
if ( !exists( $test_conf->{casedata} ) ) {
        die "data file not specified in conf file: $test_conf_file";
}
if ( !exists( $test_conf->{fieldseq} ) ) {
        die "fieldseq-data are not contained in conf file: $test_conf_file";
}

# data construction sequence data
my $fieldseq = $test_conf->{fieldseq};

# data file (input)
my $field_data_file = $test_conf->{casedata};
my $field_data      = YAML::XS::LoadFile($field_data_file);

# generated test case file (output)
my $test_case_file  = $test_conf_file;
$test_case_file =~ s/\.conf$//g;
$test_case_file = $test_case_file . '.dat';

# run!
my $test_case = generate_case( $field_data, $fieldseq );
YAML::XS::DumpFile( $test_case_file, $test_case );
