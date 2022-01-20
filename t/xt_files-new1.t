#!perl

use 5.006;
use strict;
use warnings;

use Test::More 0.88;

use XT::Files;

delete $ENV{XT_FILES_DEFAULT_CONFIG_FILE};

note('new');

is( XT::Files->_is_initialized, undef, 'singleton is not initialized' );

my $obj = XT::Files->new( -config => undef );
isa_ok( $obj, 'XT::Files', 'new returned object' );

is( XT::Files->_is_initialized, undef, '... does not initialize the singleton' );

is_deeply( $obj->{_file},     {}, '... _file is an empty hash ref' );
is_deeply( $obj->{_excludes}, [], '... _excludes is an empty array ref' );
isa_ok( $obj->{_logger}, 'XT::Files::Logger' );
is( $obj->{_logger}{_name}, 'XT::Files', '... with the correct name' );

#
done_testing();

exit 0;

# vim: ts=4 sts=4 sw=4 et: syntax=perl
