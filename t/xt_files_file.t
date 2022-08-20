#!perl

# vim: ts=4 sts=4 sw=4 et: syntax=perl
#
# Copyright (c) 2018-2022 Sven Kirmess
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

use 5.006;
use strict;
use warnings;

use Test::More 0.88;

use Cwd            ();
use File::Basename ();
use File::Spec     ();
use lib File::Spec->catdir( File::Basename::dirname( Cwd::abs_path __FILE__ ), 'lib' );

use Local::Test::Exception qw(exception);

use XT::Files::File;

delete $ENV{XT_FILES_DEFAULT_CONFIG_FILE};

like( exception { XT::Files::File->new() },   qr{\Qname attribute required\E},                               q{new throws an exception if 'name' argument is missing} );
like( exception { XT::Files::File->new(77) }, qr{\QXT::Files::File->new() got an odd number of arguments\E}, q{new throws an exception if it gets an odd number of arguments} );

{
    for my $name ( 'test 1 2 3', '0', q{} ) {
        my $obj = XT::Files::File->new( name => $name );
        isa_ok( $obj, 'XT::Files::File', 'new returned object' );

        is( $obj->{name}, $name, '... name is correctly set' );
        is( $obj->name(), $name, '... name accessor works' );
        is( "$obj",       $name, '... object stringifies to name' );
        ok( $obj, '... and is true' );
    }
}

{
    my $obj = XT::Files::File->new( { name => 'hello world' } );
    isa_ok( $obj, 'XT::Files::File', 'new returned object' );

    is( $obj->is_module, q{}, '... is_module returns empty string' );
    is( $obj->is_pod,    q{}, '... is_pod returns empty string' );
    is( $obj->is_script, q{}, '... is_script returns empty string' );
    is( $obj->is_test,   q{}, '... is_test returns empty string' );
}

{
    my $obj = XT::Files::File->new( { name => 'hello world', dir => 'lib' } );
    isa_ok( $obj, 'XT::Files::File', 'new returned object' );

    is( $obj->is_module, q{}, '... is_module returns empty string' );
    is( $obj->is_pod,    q{}, '... is_pod returns empty string' );
    is( $obj->is_script, q{}, '... is_script returns empty string' );
    is( $obj->is_test,   q{}, '... is_test returns empty string' );
}

{
    my $obj = XT::Files::File->new( { name => 'hello world', is_module => 1 } );
    isa_ok( $obj, 'XT::Files::File', 'new returned object' );

    is( $obj->is_module, 1,   '... is_module returns 1' );
    is( $obj->is_pod,    q{}, '... is_pod returns empty string' );
    is( $obj->is_script, q{}, '... is_script returns empty string' );
    is( $obj->is_test,   q{}, '... is_test returns empty string' );
}

{
    my $obj = XT::Files::File->new( name => 'hello world', is_module => 1, is_pod => 1, is_script => 1, is_test => 1 );
    isa_ok( $obj, 'XT::Files::File', 'new returned object' );

    is( $obj->is_module, 1, '... is_module returns 1' );
    is( $obj->is_pod,    1, '... is_pod returns 1' );
    is( $obj->is_script, 1, '... is_script returns 1' );
    is( $obj->is_test,   1, '... is_test returns 1' );
}

#
done_testing();

exit 0;
