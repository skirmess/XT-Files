use 5.006;
use strict;
use warnings;

use ExtUtils::MakeMaker;

my %WriteMakefileArgs = (
    ABSTRACT           => 'standard interface for author tests to find files to check',
    AUTHOR             => 'Sven Kirmess <sven.kirmess@kzone.ch>',
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    DISTNAME         => 'XT-Files',
    LICENSE          => 'open_source',
    MIN_PERL_VERSION => '5.006',
    NAME             => 'XT::Files',
    PREREQ_PM        => {
        Carp             => 0,
        Cwd              => 0,
        'File::Basename' => 0,
        'File::Find'     => 0,
        'Module::Load'   => 0,
        'Scalar::Util'   => 0,
        'Test::Builder'  => 0,
        lib              => 0,
        overload         => 0,
        parent           => 0,
        strict           => 0,
        version          => '0.81',
        warnings         => 0,
    },
    TEST_REQUIRES => {
        Exporter                => 0,
        'File::Spec'            => 0,
        'File::Temp'            => 0,
        'File::stat'            => 0,
        'Test::Builder::Tester' => 0,
        'Test::More'            => '0.88',
    },
    VERSION => '0.002',
    test    => {
        TESTS => 't/*.t',
    },
);

my %FallbackPrereqs = (
    Carp                    => 0,
    Cwd                     => 0,
    Exporter                => 0,
    'File::Basename'        => 0,
    'File::Find'            => 0,
    'File::Spec'            => 0,
    'File::Temp'            => 0,
    'File::stat'            => 0,
    'Module::Load'          => 0,
    'Scalar::Util'          => 0,
    'Test::Builder'         => 0,
    'Test::Builder::Tester' => 0,
    'Test::More'            => '0.88',
    lib                     => 0,
    overload                => 0,
    parent                  => 0,
    strict                  => 0,
    version                 => '0.81',
    warnings                => 0,
);

if ( !eval { ExtUtils::MakeMaker->VERSION('6.63_03') } ) {
    delete $WriteMakefileArgs{TEST_REQUIRES};
    delete $WriteMakefileArgs{BUILD_REQUIRES};
    $WriteMakefileArgs{PREREQ_PM} = \%FallbackPrereqs;
}

if ( !eval { ExtUtils::MakeMaker->VERSION(6.52) } ) {
    delete $WriteMakefileArgs{CONFIGURE_REQUIRES};
}

WriteMakefile(%WriteMakefileArgs);

# vim: ts=4 sts=4 sw=4 et: syntax=perl
