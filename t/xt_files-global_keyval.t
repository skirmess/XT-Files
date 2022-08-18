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

delete $ENV{XT_FILES_DEFAULT_CONFIG_FILE};

is( XT::Files->_is_initialized, undef, 'singleton is not initialized' );

my $obj = XT::Files->new( -config => undef );
isa_ok( $obj, 'XT::Files', 'new(-config => undef) returned object' );

test_out(q{# [XT::Files] Invalid entry 'invalid = entry'});
my $output = exception { $obj->_global_keyval( 'invalid', 'entry' ) };
test_test('correct error message');
like( $output, q{/Invalid entry 'invalid = entry'/}, '_global_keyval dies on unknown entries' );

is( $obj->_global_keyval( ':version', '0' ), undef, '... returns undef if the :version is ok' );

test_out(q{# [XT::Files] Not a valid version 'hello world'});
$output = exception { $obj->_global_keyval( ':version', 'hello world' ) };
test_test('correct error message');
like( $output, q{/Not a valid version 'hello world'/}, '... dies if the specified version does not pass version->is_lax' );

test_out("# [XT::Files] XT::Files version 99999999 required--this is only version $XT::Files::VERSION");
$output = exception { $obj->_global_keyval( ':version', '99999999' ) };
test_test('correct error message');
like( $output, '/XT::Files version 99999999 required--this is only version /', '... dies if the :version is not ok' );

#
done_testing();

exit 0;
