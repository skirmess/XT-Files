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
use XT::Files::Plugin;

delete $ENV{XT_FILES_DEFAULT_CONFIG_FILE};

my $obj = XT::Files::Plugin->new( xtf => XT::Files->new );
isa_ok( $obj, 'XT::Files::Plugin', 'new returned object' );

test_out(q{# [XT::Files::Plugin] this is a test 103});
$obj->log('this is a test 103');
test_test('correct error message');

$ENV{XT_FILES_DEBUG} = 1;
test_out(q{# [XT::Files::Plugin] this is a test 127});
$obj->log_debug('this is a test 127');
test_test('correct error message');

delete $ENV{XT_FILES_DEBUG};
test_out();
$obj->log_debug('this is a test 131');
test_test('correct error message');

#
done_testing();

exit 0;
