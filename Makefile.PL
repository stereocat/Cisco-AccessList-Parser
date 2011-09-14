use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Cisco::AccessList::Parser',
    AUTHOR              => 'stereocat <stereocat@gmail.com>',
    VERSION_FROM        => 'lib/Cisco/AccessList/Parser.pm',
    ABSTRACT_FROM       => 'lib/Cisco/AccessList/Parser.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'version'    => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Cisco-AccessList-Parser-*' },
);
