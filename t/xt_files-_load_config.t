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

chdir 'corpus/dist1' or die "chdir failed: $!";

is( XT::Files->_is_initialized, undef, 'singleton is not initialized' );

my $obj = XT::Files->new( -config => undef );
isa_ok( $obj, 'XT::Files', 'new returned object' );

test_out(qr{[#]\Q [XT::Files] Cannot read file 'non existing file.txt': \E.*\n?});
my $output = exception { $obj->_load_config('non existing file.txt') };
test_test('correct error message');
like( $output, q{/Cannot read file 'non existing file.txt': /}, '_load_config dies if the config file cannot be read' );

#
done_testing();

exit 0;
