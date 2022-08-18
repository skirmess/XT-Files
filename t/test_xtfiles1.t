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

use Test::XTFiles;
use XT::Files;

delete $ENV{XT_FILES_DEFAULT_CONFIG_FILE};

chdir 'corpus/empty' or die "chdir failed: $!";

is( XT::Files->_is_initialized, undef, 'singleton is not initialized' );

my $obj = Test::XTFiles->new();
isa_ok( $obj, 'Test::XTFiles', 'new returned object' );

ok( XT::Files->_is_initialized(), '... and initializes the singleton' );

is_deeply( $obj->{_files}, [], '... _files returns an empty hash ref' );

my @files = $obj->files;
is( scalar @files, 0, 'files returns 0 files' );

@files = $obj->all_files;
is( scalar @files, 0, 'all_files returns 0 files' );

@files = $obj->all_module_files;
is( scalar @files, 0, 'all_module_files returns 0 files' );

@files = $obj->all_executable_files;
is( scalar @files, 0, 'all_executable_files returns 0 files' );

@files = $obj->all_perl_files;
is( scalar @files, 0, 'all_perl_files returns 0 files' );

@files = $obj->all_pod_files;
is( scalar @files, 0, 'all_pod_files returns 0 files' );

@files = $obj->all_test_files;
is( scalar @files, 0, 'all_test_files returns 0 files' );

done_testing();

exit 0;
