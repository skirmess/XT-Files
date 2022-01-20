#!perl

use 5.006;
use strict;
use warnings;

use Test::More 0.88;

use XT::Files;

delete $ENV{XT_FILES_DEFAULT_CONFIG_FILE};

is( XT::Files->_is_initialized, undef, 'singleton is not initialized' );
my $obj = XT::Files->instance;
isa_ok( $obj, 'XT::Files', 'instance returned object' );

is( XT::Files->_is_initialized, 1, '... and initializes the singleton' );

my $obj2 = XT::Files->instance;
isa_ok( $obj2, 'XT::Files', 'instance returned object' );

is( $obj, $obj2, '... the same' );

done_testing();

exit 0;

# vim: ts=4 sts=4 sw=4 et: syntax=perl
