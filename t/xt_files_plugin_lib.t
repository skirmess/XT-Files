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

use Cwd        qw(abs_path cwd);
use File::Temp ();

use File::Basename ();
use File::Spec     ();
use lib File::Spec->catdir( File::Basename::dirname( Cwd::abs_path __FILE__ ), 'lib' );

use Local::Test::Exception qw(exception);

use XT::Files::Plugin::lib;

delete $ENV{XT_FILES_DEFAULT_CONFIG_FILE};

like( exception { XT::Files::Plugin::lib->new() }, q{/xtf attribute required/}, q{new throws an exception if 'xtf' argument is missing} );

like( exception { XT::Files::Plugin::lib->new( xtf => 'hello world' ) }, q{/'xtf' is not of class 'XT::Files'/}, q{new throws an exception if 'xtf' argument is not an XT::Files object} );

my $cwd = cwd();

# lib->import does some normalizing of @INC. We run this once before we take the reference.
my $empty_dir = File::Temp->newdir();
lib->import( abs_path($empty_dir) );

my @INC_pre = @INC;

my $mock = bless {}, 'XT::Files';
my $obj  = XT::Files::Plugin::lib->new( xtf => $mock );
isa_ok( $obj, 'XT::Files::Plugin::lib', 'new returned object' );

is( $obj->run(), undef, 'run returns undef' );
is_deeply( \@INC_pre, \@INC, '... and does not change @INC if no lib dir is specified' );    ## no critic (ValuesAndExpressions::RequireInterpolationOfMetachars)

my $expected_output = q{[XT::Files::Plugin::lib] Invalid configuration option 'hello = world' for plugin 'lib'};
test_out("# $expected_output");
my $output = exception { $obj->run( [ [ hello => 'world' ] ] ) };
test_test('correct error message');
like( $output, qr{\Q$expected_output\E}, 'run throws an exception if a wrong config option is used' );
is_deeply( \@INC_pre, \@INC, '... and does not change @INC if no lib dir is specified' );    ## no critic (ValuesAndExpressions::RequireInterpolationOfMetachars)

my $dir = File::Temp->newdir();
chdir $dir or die "chdir failed: $!";

mkdir 'lib' or die "mkdir failed: $!";

is( $obj->run( [ [ lib => 'lib2' ] ] ), undef, 'run returns undef' );
is_deeply( \@INC_pre, \@INC, '... and does not change @INC if no lib dir is specified' );    ## no critic (ValuesAndExpressions::RequireInterpolationOfMetachars)

my $lib = abs_path('lib');
is( $obj->run( [ [ lib => 'lib' ] ] ), undef, 'run returns undef' );
is_deeply( [ $lib, @INC_pre ], \@INC, '... and does add the new lib dir to @INC' );          ## no critic (ValuesAndExpressions::RequireInterpolationOfMetachars)

# required for File::Temp to remove dir at end
chdir $cwd;                                                                                  ## no critic (InputOutput::RequireCheckedSyscalls)

note('test log_prefix');

$obj             = XT::Files::Plugin::lib->new( xtf => $mock, name => 'hello world' );
$expected_output = q{[hello world] Invalid configuration option 'hello = world' for plugin 'lib'};
test_out("# $expected_output");
$output = exception { $obj->run( [ [ hello => 'world' ] ] ) };
test_test('correct error message');
like( $output, qr{\Q$expected_output\E}, 'run throws an exception if a wrong config option is used' );

#
done_testing();

exit 0;
