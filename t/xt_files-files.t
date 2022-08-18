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

use XT::Files;

delete $ENV{XT_FILES_DEFAULT_CONFIG_FILE};

chdir 'corpus/dist1' or die "chdir failed: $!";

is( XT::Files->_is_initialized, undef, 'singleton is not initialized' );

my $obj = XT::Files->new( -config => undef );

is( $obj->bin_dir('bin'),    undef, 'bin_dir returns undef' );
is( $obj->module_dir('lib'), undef, 'module_dir returns undef' );
is( $obj->test_dir('t'),     undef, 'test_dir returns undef' );

my @files = $obj->files;
is( scalar @files, 5, 'files returns 5 file objects' );
for my $i ( 0 .. $#files ) {
    isa_ok( $files[$i], 'XT::Files::File' );
}

my @file_names = map { $_->name } @files;
is_deeply( [@file_names], [ sort qw(t/test.t lib/world.pm lib/world.pod bin/hello.txt bin/world.txt) ], '... with the correct names' );

#
is( $obj->ignore_file('bin/hello.txt'), undef, 'ignore_file returns undef' );

@files = $obj->files;
is( scalar @files, 4, 'files returns 4 file objects' );
for my $i ( 0 .. $#files ) {
    isa_ok( $files[$i], 'XT::Files::File' );
}

@file_names = map { $_->name } @files;
is_deeply( [@file_names], [ sort qw(t/test.t lib/world.pm lib/world.pod bin/world.txt) ], '... with the correct names' );

#
$obj->exclude(qr{ [.] txt $ }x);

@files = $obj->files;
is( scalar @files, 3, 'files returns 3 file objects' );
for my $i ( 0 .. $#files ) {
    isa_ok( $files[$i], 'XT::Files::File' );
}

@file_names = map { $_->name } @files;
is_deeply( [@file_names], [ sort qw(t/test.t lib/world.pm lib/world.pod) ], '... with the correct names' );

#
$obj->exclude('^world\.');

@files = $obj->files;
is( scalar @files, 1, 'files returns 1 file objects' );
for my $i ( 0 .. $#files ) {
    isa_ok( $files[$i], 'XT::Files::File' );
}

@file_names = map { $_->name } @files;
is_deeply( [@file_names], [ sort qw(t/test.t) ], '... with the correct names' );

#
is( $obj->bin_file('does_not_exist'), undef, 'adding a non-existing file' );

@files = $obj->files;
is( scalar @files, 1, 'files returns 1 file objects' );

for my $i ( 0 .. $#files ) {
    isa_ok( $files[$i], 'XT::Files::File' );
}

@file_names = map { $_->name } @files;
is_deeply( [@file_names], [ sort qw(t/test.t) ], '... with the correct names' );

#
done_testing();

exit 0;
