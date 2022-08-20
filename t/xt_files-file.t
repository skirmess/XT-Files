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

use Cwd            ();
use File::Basename ();
use File::Spec     ();
use lib File::Spec->catdir( File::Basename::dirname( Cwd::abs_path __FILE__ ), 'lib' );

use Local::Test::Exception qw(exception);

use XT::Files;
use XT::Files::File;

delete $ENV{XT_FILES_DEFAULT_CONFIG_FILE};

note('file');

is( XT::Files->_is_initialized, undef, 'singleton is not initialized' );

my $obj = XT::Files->new( -config => undef );

is( $obj->file('hello'), undef, 'file returns undef if the file does not exist' );

$obj->{_file}->{'hello'} = 'world';
is( $obj->file('hello'), 'world', 'file returns the file obj if it does exist' );

is( $obj->file( 'hello', undef ), undef, 'file(name, undef) removes an entry' );
is( $obj->file('hello'),          undef, 'file returns undef if the file does not exist' );
ok( exists $obj->{_file}->{'hello'}, q{entry for file 'hello' still exists} );

my $file_obj = XT::Files::File->new( name => 'hello' );

is( $obj->file( 'hello', $file_obj ), $file_obj, 'file(name, obj) inserts an entry' );
isa_ok( $obj->file('hello'), 'XT::Files::File' );

test_out(q{# [XT::Files] File is not of class 'XT::Files::File'});
my $exception = exception { $obj->file( 'hello', bless {}, 'Local::Something' ) };
test_test();

like( $exception, qr{File is not of class 'XT::Files::File'}, 'file(name, obj) throws an error if obj is not from class XT::Files::File' );

done_testing();

exit 0;
