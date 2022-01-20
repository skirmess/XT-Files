#!perl

use 5.006;
use strict;
use warnings;

use Test::Fatal;
use Test::More 0.88;

use XT::Files::Plugin;

delete $ENV{XT_FILES_DEFAULT_CONFIG_FILE};

like( exception { XT::Files::Plugin->new() }, q{/xtf attribute required/}, q{new throws an exception if 'xtf' argument is missing} );

like( exception { XT::Files::Plugin->new( xtf => 'hello world' ) }, q{/'xtf' is not of class 'XT::Files'/}, q{new throws an exception if 'xtf' argument is not an XT::Files object} );

my $xtf = bless {}, 'XT::Files';

my $obj = XT::Files::Plugin->new( xtf => $xtf );
isa_ok( $obj,      'XT::Files::Plugin', 'new returned object' );
isa_ok( $obj->xtf, 'XT::Files',         'xtf return object' );
is( $obj->xtf,    $xtf,                '... the one we passed it' );
is( $obj->{name}, 'XT::Files::Plugin', '... name is set to class name' );
isa_ok( $obj->{_logger}, 'XT::Files::Logger' );
is( $obj->{_logger}->{_name}, 'XT::Files::Plugin', '... name is set to class name' );

$obj = XT::Files::Plugin->new( xtf => $xtf, name => 'hello world' );
isa_ok( $obj,      'XT::Files::Plugin', 'new returned object' );
isa_ok( $obj->xtf, 'XT::Files',         'xtf return object' );
is( $obj->xtf,    $xtf,          '... the one we passed it' );
is( $obj->{name}, 'hello world', '... name is set to argument' );
isa_ok( $obj->{_logger}, 'XT::Files::Logger' );
is( $obj->{_logger}->{_name}, 'hello world', '... name is set to argument' );

#
done_testing();

exit 0;

# vim: ts=4 sts=4 sw=4 et: syntax=perl
