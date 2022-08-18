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

my %file = %{ $obj->{_file} };
my @keys = keys %file;

is( scalar @keys, 4, '... now we have 4 files' );
for my $i ( 0 .. $#keys ) {
    my $name = $keys[$i];
    my $file = $file{$name};

    if ( $name =~ m{ ^ bin / }x ) {
        isa_ok( $file, 'XT::Files::File' );
        is( $file->name, $file{$name}, "... with name '$name'" );
        ok( !$file->is_module, 'is_module is false' );
        ok( !$file->is_pod,    'is_pod is false' );
        ok( $file->is_script,  'is_script is true' );
        ok( !$file->is_test,   'is_test is false' );
    }
    elsif ( $name =~ m { ^ lib / .* [.] pm $ }x ) {
        isa_ok( $file, 'XT::Files::File' );
        is( $file->name, $file{$name}, "... with name '$name'" );
        ok( $file->is_module,  'is_module is true' );
        ok( !$file->is_pod,    'is_pod is false' );
        ok( !$file->is_script, 'is_script is false' );
        ok( !$file->is_test,   'is_test is false' );
    }
    elsif ( $name =~ m { ^ lib / .* [.] pod $ }x ) {
        isa_ok( $file, 'XT::Files::File' );
        is( $file->name, $file{$name}, "... with name '$name'" );
        ok( !$file->is_module, 'is_module is false' );
        ok( $file->is_pod,     'is_pod is true' );
        ok( !$file->is_script, 'is_script is false' );
        ok( !$file->is_test,   'is_test is false' );
    }
    else {
        ok( 0, "unexpected file $file{$name}" );
    }
}

#
done_testing();

exit 0;
