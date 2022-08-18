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

use Scalar::Util qw(blessed);

use Test::XTFiles;
use XT::Files;

delete $ENV{XT_FILES_DEFAULT_CONFIG_FILE};

chdir 'corpus/dist4' or die "chdir failed: $!";

is( XT::Files->_is_initialized, undef, 'singleton is not initialized' );

my $obj = Test::XTFiles->new();
isa_ok( $obj, 'Test::XTFiles', 'new returned object' );

# files
my @files = $obj->files;
is( scalar @files, 6, 'files returns 6 files' );

for my $i ( 0 .. $#files ) {
    isa_ok( $files[$i], 'XT::Files::File' );
}

is( $files[0]->name, 'bin/hello.txt',           '... correct name' );
is( $files[1]->name, 'bin/lib/module.pm',       '... correct name' );
is( $files[2]->name, 'bin/lib/not_a_module.pl', '... correct name' );
is( $files[3]->name, 'bin/world.txt',           '... correct name' );
is( $files[4]->name, 'lib/world.pm',            '... correct name' );
is( $files[5]->name, 'lib/world.pod',           '... correct name' );

# all_files
@files = $obj->all_files;

is( scalar @files, 6, 'all_files returns 6 files' );

for my $i ( 0 .. $#files ) {
    is( blessed( $files[$i] ), undef, 'returned file is not an object' );
}

is( $files[0], 'bin/hello.txt',           '... correct name' );
is( $files[1], 'bin/lib/module.pm',       '... correct name' );
is( $files[2], 'bin/lib/not_a_module.pl', '... correct name' );
is( $files[3], 'bin/world.txt',           '... correct name' );
is( $files[4], 'lib/world.pm',            '... correct name' );
is( $files[5], 'lib/world.pod',           '... correct name' );

# all_module_files
@files = $obj->all_module_files;

is( scalar @files, 1, 'all_module_files returns one file' );

for my $i ( 0 .. $#files ) {
    is( blessed( $files[$i] ), undef, 'returned file is not an object' );
}

is( $files[0], 'lib/world.pm', '... correct name' );

# all_executable_files
@files = $obj->all_executable_files;

is( scalar @files, 4, 'all_executable_files returns 4 file' );

for my $i ( 0 .. $#files ) {
    is( blessed( $files[$i] ), undef, 'returned file is not an object' );
}

is( $files[0], 'bin/hello.txt',           '... correct name' );
is( $files[1], 'bin/lib/module.pm',       '... correct name' );
is( $files[2], 'bin/lib/not_a_module.pl', '... correct name' );
is( $files[3], 'bin/world.txt',           '... correct name' );

# all_perl_files
@files = $obj->all_perl_files;

is( scalar @files, 5, 'all_perl_files returns 5 file' );

for my $i ( 0 .. $#files ) {
    is( blessed( $files[$i] ), undef, 'returned file is not an object' );
}

is( $files[0], 'bin/hello.txt',           '... correct name' );
is( $files[1], 'bin/lib/module.pm',       '... correct name' );
is( $files[2], 'bin/lib/not_a_module.pl', '... correct name' );
is( $files[3], 'bin/world.txt',           '... correct name' );
is( $files[4], 'lib/world.pm',            '... correct name' );

# all_pod_files
@files = $obj->all_pod_files;

is( scalar @files, 1, 'all_pod_files returns one file' );

for my $i ( 0 .. $#files ) {
    is( blessed( $files[$i] ), undef, 'returned file is not an object' );
}

is( $files[0], 'lib/world.pod', '... correct name' );

# all_test_files
@files = $obj->all_test_files;

is( scalar @files, 0, 'all_test_files returns no files' );

done_testing();

exit 0;
