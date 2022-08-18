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

use Test::Builder::Tester;
use Test::Fatal;
use Test::More 0.88;

use XT::Files;
use XT::Files::Plugin::Excludes;

delete $ENV{XT_FILES_DEFAULT_CONFIG_FILE};

like( exception { XT::Files::Plugin::Excludes->new() }, q{/xtf attribute required/}, q{new throws an exception if 'xtf' argument is missing} );

like( exception { XT::Files::Plugin::Excludes->new( xtf => 'hello world' ) }, q{/'xtf' is not of class 'XT::Files'/}, q{new throws an exception if 'xtf' argument is not an XT::Files object} );

my $xtf = XT::Files->new( -config => undef );
is_deeply( $xtf->{_excludes}, [], 'no excludes are configured' );

my $obj = XT::Files::Plugin::Excludes->new( xtf => $xtf );
isa_ok( $obj, 'XT::Files::Plugin::Excludes', 'new returned object' );

is( $obj->run(), undef, 'run returns undef' );
is_deeply( $xtf->{_excludes}, [], 'no excludes are configured' );

my $expected_output = q{[XT::Files::Plugin::Excludes] Invalid configuration option 'hello = world' for plugin 'Excludes'};
test_out("# $expected_output");
my $output = exception { $obj->run( [ [ hello => 'world' ] ] ) };
test_test('correct error message');
like( $output, qr{\Q$expected_output\E}, 'run dies if an invalid argument is given' );
is_deeply( $xtf->{_excludes}, [], 'no excludes are configured' );

is( $obj->run( [ [ exclude => 'hello' ], [ exclude => '.*world$' ] ] ), undef, 'run returns undef' );
is_deeply( $xtf->{_excludes}, [ 'hello', '.*world$' ], 'correct excludes are configured' );

#
done_testing();

exit 0;
