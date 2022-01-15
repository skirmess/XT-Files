#!perl

use 5.006;
use strict;
use warnings;

use Test::Fatal;
use Test::More 0.88;

use XT::Files;
use XT::Files::Plugin;

like( exception { XT::Files::Plugin->new(77); }, qr{\QXT::Files::Plugin->new() got an odd number of arguments\E}, 'new() throws an exception with an odd number of arguments' );

my $xtf = XT::Files->new;

my $obj = XT::Files::Plugin->new( xtf => $xtf, name => 'test 101' );
isa_ok( $obj, 'XT::Files::Plugin', 'new returns a XT::Files::Plugin object (argument as array)' );
is( $obj->{xtf},  $xtf,       '... with the correct XT::Files object' );
is( $obj->{name}, 'test 101', '... and the correct name' );

$obj = XT::Files::Plugin->new( { xtf => $xtf, name => 'test 103' } );
isa_ok( $obj, 'XT::Files::Plugin', 'new returns a XT::Files::Plugin object (argument as hash ref)' );
is( $obj->{xtf},  $xtf,       '... with the correct XT::Files object' );
is( $obj->{name}, 'test 103', '... and the correct name' );

#
done_testing();

exit 0;

# vim: ts=4 sts=4 sw=4 et: syntax=perl
