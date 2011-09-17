use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name    => 'Cisco::AccessList::Parser',
    dynamic_config => 1,
    PL_files       => {
        'lib/Cisco/AccessList/Parser.pm.PL' =>
            'lib/Cisco/AccessList/Parser.pm',
        'generate_tests.PL' => [
            't/10-stdacl.t',
            't/20-extacl-icmp.t',
            't/21-extacl-ip.t',
            't/22-extacl-tcp.t',
            't/23-extacl-udp.t',
            't/24-extacl-objgrp1.t',
            't/25-extacl-objgrp2.t',
            't/26-extacl-objgrp3.t',
            't/27-extacl-options1.t',
            't/28-extacl-options2.t'
        ],
    },
    license            => 'perl',
    dist_author        => 'stereocat <stereocat@gmail.com>',
    dist_version_from  => 'lib/Cisco/AccessList/Parser.eyp',
    dist_abstract      => 'Cisco access-list parse',
    configure_requires => { 'Module::Build' => 0.36, },
    requires           => {
        'Parse::Eyapp' => 1.181,
        'version'      => 0,
    },
    build_requires => {
        'YAML'       => 0,
        'Test::More' => 0.92,
        'Test::Base' => 0.60,
    },
    add_to_cleanup => ['Cisco-AccessList-Parser-*'],
);

$builder->create_build_script();

