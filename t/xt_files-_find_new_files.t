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

use Cwd;
use File::Temp;

use XT::Files;

delete $ENV{XT_FILES_DEFAULT_CONFIG_FILE};

my $cwd = cwd();

chdir 'corpus/dist1' or die "chdir failed: $!";

is( XT::Files->_is_initialized, undef, 'singleton is not initialized' );

my $obj = XT::Files->new( -config => undef );

my @files = $obj->_find_new_files('bin');

is( scalar @files, 2, '_find_new_files returns two files' );
is_deeply( [ sort @files ], [ sort qw(bin/hello.txt bin/world.txt) ], '... the correct ones' );

#
$obj->ignore_file('bin/hello.txt');

@files = $obj->_find_new_files('bin');

is( scalar @files, 1, '_find_new_files returns one files' );
is_deeply( [ sort @files ], ['bin/world.txt'], '... the correct one' );

#
local $ENV{XT_FILES_DEBUG} = 0;

test_out();
@files = $obj->_find_new_files('no_such_dir');
test_test('nothing printed');
is_deeply( \@files, [], '... nothing found' );

#
local $ENV{XT_FILES_DEBUG} = 1;

test_out('# [XT::Files] Directory no_such_dir does not exist or is not a directory');
@files = $obj->_find_new_files('no_such_dir');
test_test('... correct warning printed');
is_deeply( \@files, [], '... nothing found' );

SKIP: {
    skip 'The symlink function is unimplemented', 1 if !eval {
        symlink q{}, q{};    ## no critic (InputOutput::RequireCheckedSyscalls)
        1;
    };

    my $dir = File::Temp->newdir();

    chdir $dir or die "chdir failed: $!";

    mkdir 'bin'   or die "mkdir failed: $!";
    mkdir 'bin/a' or die "mkdir failed: $!";

    mkdir 'bin2'   or die "mkdir failed: $!";
    mkdir 'bin2/b' or die "mkdir failed: $!";
    symlink '../bin2/b', 'bin/b' or die "symlink failed: $!";

    open my $fh, '>', 'bin/hello.txt'    or die "open failed: $!";
    open $fh,    '>', 'bin/a/world.txt'  or die "open failed: $!";
    open $fh,    '>', 'bin2/b/world.txt' or die "open failed: $!";

    symlink 'world.txt', 'bin/a/world2.txt' or die "symlink failed: $!";

    $obj = XT::Files->new( -config => undef );
    isa_ok( $obj, 'XT::Files', 'new() returns a XT::Files object' );

    @files = $obj->_find_new_files('bin');

    is( scalar @files, 2, '_find_new_files returns two files' );
    is_deeply( [ sort @files ], [ sort qw(bin/hello.txt bin/a/world.txt) ], '... the correct ones (symlinks are skipped)' );

    # required for File::Temp to remove dir at end
    chdir $cwd;    ## no critic (InputOutput::RequireCheckedSyscalls)
}

#
done_testing();

exit 0;
