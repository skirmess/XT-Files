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
use XT::Files::Plugin::Default;

delete $ENV{XT_FILES_DEFAULT_CONFIG_FILE};

like( exception { XT::Files::Plugin::Default->new() }, q{/xtf attribute required/}, q{new throws an exception if 'xtf' argument is missing} );

is( XT::Files->_is_initialized, undef, 'singleton is not initialized' );

my $xtf = XT::Files->new( -config => undef );
is_deeply( $xtf->{_excludes}, [], 'no excludes are configured' );

my $obj = XT::Files::Plugin::Default->new( xtf => $xtf );
isa_ok( $obj, 'XT::Files::Plugin::Default', 'new returned object' );

is( $obj->run( [ [ dirs => 0 ], [ excludes => 0 ] ] ), undef, 'run returns undef' );
is_deeply( $xtf->{_excludes}, [], 'no excludes are configured' );
is_deeply( $xtf->{_file},     {}, 'no files are found' );

my $expected_output = q{[XT::Files::Plugin::Default] Invalid configuration option 'hello = world' for plugin 'Default'};
test_out("# $expected_output");
my $output = exception { $obj->run( [ [ hello => 'world' ] ] ) };
test_test('correct error message');
like( $output, qr{\Q$expected_output\E}, 'run dies if an invalid argument is given' );

is_deeply( $xtf->{_excludes}, [], 'no excludes are configured' );
is_deeply( $xtf->{_file},     {}, 'no files are found' );

is( $obj->run( [ [ dirs => 0 ] ] ), undef, 'run returns undef' );
is_deeply( $xtf->{_excludes}, [ q{[.]swp$}, q{[.]bak$}, q{~$} ], 'default excludes are configured' );
is_deeply( $xtf->{_file},     {},                                'no files are found' );

#
done_testing();

exit 0;
