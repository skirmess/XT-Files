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
use XT::Files::Plugin;

like( exception { XT::Files::Plugin->new(77); }, qr{\QXT::Files::Plugin->new() got an odd number of arguments\E}, 'new() throws an exception with an odd number of arguments' );

my $xtf = XT::Files->new;

my $obj = XT::Files::Plugin->new( xtf => $xtf, name => 'test 101' );
isa_ok( $obj, 'XT::Files::Plugin', 'new returns a XT::Files::Plugin object (argument as array)' );
is( $obj->{xtf},  $xtf,       '... with the correct XT::Files object' );
is( $obj->{name}, 'test 101', '... and the correct name' );

$obj = XT::Files::Plugin->new( { xtf => $xtf, name => 'test 103' } );
isa_ok( $obj, 'XT::Files::Plugin', 'new returns a XT::Files::Plugin object (argument as hash ref)' );
is( $obj->{xtf},  $xtf,       '... with the correct XT::Files object' );
is( $obj->{name}, 'test 103', '... and the correct name' );

#
done_testing();

exit 0;
