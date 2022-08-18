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
use Test::More 0.88;

use XT::Files;

delete $ENV{XT_FILES_DEFAULT_CONFIG_FILE};

chdir 'corpus/dist1' or die "chdir failed: $!";

my $config = "\t# hello\n    ; world\n \t \t :version \t =\t0.001 \t \t ";
my $obj    = XT::Files->new( -config => \$config );
isa_ok( $obj, 'XT::Files', 'new returned object' );

test_out(q{# [XT::Files] this is a test 103});
$obj->log('this is a test 103');
test_test('correct error message');

#
done_testing();

exit 0;
