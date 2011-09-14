use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Cisco::AccessList::Parser',
    license             => 'perl',
    dist_author         => 'stereocat <stereocat@gmail.com>',
    dist_version_from   => 'lib/Cisco/AccessList/Parser.pm',
    requires => {
        'Test::More' => 0,
        'version'    => 0,
    },
    add_to_cleanup      => [ 'Cisco-AccessList-Parser-*' ],
);

$builder->create_build_script();
