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

use XT::Files::Logger;

delete $ENV{XT_FILES_DEBUG};
delete $ENV{XT_FILES_DEFAULT_CONFIG_FILE};

my $prefix = 'PrEfIx';

note(q{log('hello world')});
{
    my $obj = XT::Files::Logger->new( name => $prefix );
    isa_ok( $obj, 'XT::Files::Logger', "new(name => $prefix) returns an XT::Files::Logger object" );
    is( $obj->{_name}, $prefix, '... with the correct name' );

    test_out("# [$prefix] hello world");
    my $result = $obj->log('hello world');
    test_test('log output');
    is( $result, undef, 'log() returns undef' );

    test_out("# [$prefix] hello\n# world");
    $result = $obj->log("hello\nworld");
    test_test('log output');
    is( $result, undef, 'log() returns undef' );
}

note(q{log_debug('hello world')});
{
    my $obj = XT::Files::Logger->new( { name => $prefix } );
    isa_ok( $obj, 'XT::Files::Logger', "new({name => $prefix}) returns an XT::Files::Logger object" );
    is( $obj->{_name}, $prefix, '... with the correct name' );

    # no debug output
    test_out();
    my $result = $obj->log_debug('hello world');
    test_test('log_debug output');
    is( $result, undef, 'log_debug() returns undef' );

    # with debug output
    local $ENV{XT_FILES_DEBUG} = 1;

    test_out("# [$prefix] hello world");
    $result = $obj->log_debug('hello world');
    test_test('log_debug output');
    is( $result, undef, 'log_debug() returns undef' );

}

note(q{log_fatal('hello world')});
{
    my $obj = XT::Files::Logger->new( name => $prefix );
    isa_ok( $obj, 'XT::Files::Logger', "new(name => $prefix) returns an XT::Files::Logger object" );
    is( $obj->{_name}, $prefix, '... with the correct name' );

    test_out("# [$prefix] hello world");
    my $output = exception { $obj->log_fatal('hello world'); };
    test_test('log_fatal output');

    my $expected_die = "[$prefix] hello world at ";
    like( $output, qr{\Q$expected_die\E}, '... and expected die message' );

}

note('usage error');
{
    my $e = exception { XT::Files::Logger->new( name => $prefix, 77 ); };
    like( $e, qr{\QXT::Files::Logger->new() got an odd number of arguments\E}, 'new throws an exception with an odd number of arguments' );

    $e = exception { XT::Files::Logger->new; };
    like( $e, qr{\Qname attribute required\E}, 'new throws an exception if name is not given' );
}

#
done_testing();

exit 0;
