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

use File::stat;
use File::Temp;

use XT::Files;

delete $ENV{XT_FILES_DEFAULT_CONFIG_FILE};

chdir 'corpus/dist1' or die "chdir failed: $!";

is( XT::Files->_is_initialized, undef, 'singleton is not initialized' );

my $tempdir          = File::Temp->newdir();
my $report_file_base = "$tempdir/report_" . __LINE__;
local $ENV{REPORT_FILE_BASE} = $report_file_base;

my $obj = XT::Files->new;
isa_ok( $obj, 'XT::Files', 'new returned object' );

my $st = stat "${report_file_base}.new";
ok( defined $st, '... new was run' );
if ( defined $st ) {
    is( $st->size, 0, '... without arguments' );
}

my $rc = open my $fh, '<', "${report_file_base}.run";
ok( $rc, '... plugins run was run' );
if ($rc) {
    my @lines = <$fh>;
    close $fh or die "chdir failed: $!";
    chomp @lines;
    is_deeply( \@lines, [ ':nk1=nv1', ':n k 2=n v 2', 'k1=v1', 'k 2=hello world' ], '... with the correct arguments' );
}

#
done_testing();

exit 0;
