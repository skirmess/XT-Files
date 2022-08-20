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

use Cwd            ();
use File::Basename ();
use File::Spec     ();
use lib File::Spec->catdir( File::Basename::dirname( Cwd::abs_path __FILE__ ), 'lib' );

use Local::Test::Exception qw(exception);

use XT::Files;

delete $ENV{XT_FILES_DEFAULT_CONFIG_FILE};

note('initialize');

is( XT::Files->_is_initialized(), undef, 'singleton is not initialized' );
my $obj = XT::Files->initialize( -config => undef );
isa_ok( $obj, 'XT::Files', 'initialize returned object' );

is( XT::Files->_is_initialized(), 1, '... and initializes the singleton' );

is_deeply( $obj->{_file},     {}, '... _file is an empty hash ref' );
is_deeply( $obj->{_excludes}, [], '... _excludes is an empty array ref' );

like( exception { XT::Files->initialize( -config => undef ); }, qr{XT::Files is already initialized}, 'calling initialize twice throws an exception' );

done_testing();

exit 0;
