#!perl

use 5.006;
use strict;
use warnings;

use Test::Fatal;
use Test::More 0.88;

use XT::Files;

delete $ENV{XT_FILES_DEFAULT_CONFIG_FILE};

note('initialize');

is( XT::Files->_is_initialized(), undef, 'singleton is not initialized' );
my $obj = XT::Files->initialize( -config => undef );
isa_ok( $obj, 'XT::Files', 'initialize returned object' );

is( XT::Files->_is_initialized(), 1, '... and initializes the singleton' );

is_deeply( $obj->{_file},     {}, '... _file is an empty hash ref' );
is_deeply( $obj->{_excludes}, [], '... _excludes is an empty array ref' );

like( exception { XT::Files->initialize( -config => undef ); }, qr{XT::Files is already initialized}, 'calling initialize twice throws an exception' );

done_testing();

exit 0;

# vim: ts=4 sts=4 sw=4 et: syntax=perl
