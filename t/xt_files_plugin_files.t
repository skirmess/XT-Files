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

use File::Basename ();
use File::Spec     ();
use lib File::Spec->catdir( File::Basename::dirname( Cwd::abs_path __FILE__ ), 'lib' );

use Local::Test::Exception qw(exception);

use XT::Files;
use XT::Files::Plugin::Files;

delete $ENV{XT_FILES_DEFAULT_CONFIG_FILE};

like( exception { XT::Files::Plugin::Files->new() }, q{/xtf attribute required/}, q{new throws an exception if 'xtf' argument is missing} );

like( exception { XT::Files::Plugin::Files->new( xtf => 'hello world' ) }, q{/'xtf' is not of class 'XT::Files'/}, q{new throws an exception if 'xtf' argument is not an XT::Files object} );

my $cwd = cwd();

chdir 'corpus/dist1' or die "chdir failed: $!";

is( XT::Files->_is_initialized, undef, 'singleton is not initialized' );

my $xtf = XT::Files->new( -config => undef );
is_deeply( [ $xtf->files ], [], 'no files are configured' );

my $obj = XT::Files::Plugin::Files->new( xtf => $xtf );
isa_ok( $obj, 'XT::Files::Plugin::Files', 'new returned object' );

is( $obj->run(), undef, 'run returns undef' );
is_deeply( [ $xtf->files ], [], 'no files are configured' );

my $expected_output = q{[XT::Files::Plugin::Files] Invalid configuration option 'hello = world' for plugin 'Files'};
test_out("# $expected_output");
my $output = exception { $obj->run( [ [ hello => 'world' ] ] ) };
test_test('correct error message');
like( $output, qr{\Q$expected_output\E}, 'run dies if an invalid argument is given' );
is_deeply( [ $xtf->files ], [], 'no files are configured' );

is( $obj->run( [ [ bin => 'bin/world.txt' ], [ bin => 'bin/hello.txt' ], [ module => 'lib/world.pl' ], [ module => 'lib/world.pm' ], [ test => 't/test.t' ], [ test => 't/test.pl' ], [ pod => 'lib/world.pod' ] ] ), undef, 'run returns undef' );

my @files = $xtf->files;
is( scalar @files, 7, '... found 7 files' );

my %expected_file;
for my $name (qw(bin/hello.txt bin/world.txt)) {
    $expected_file{$name} = _check_bin_file($name);
}
for my $name (qw(lib/world.pl lib/world.pm)) {
    $expected_file{$name} = _check_module_file($name);
}
for my $name (qw(lib/world.pod)) {
    $expected_file{$name} = _check_pod_file($name);
}
for my $name (qw(t/test.t t/test.pl)) {
    $expected_file{$name} = _check_test_file($name);
}

for my $name ( sort keys %expected_file ) {
    if ( !@files ) {
        ok( 0, "expected file not found: $name" );
    }
    else {
        my $file = shift @files;
        $expected_file{$name}->($file);
    }
}

for my $file (@files) {
    ok( 0, 'file found but not expected: ' . $file->name() );
}

#
note('non existing file / directory / symlink');

is( XT::Files->_is_initialized, undef, 'singleton is not initialized' );

my $dir = File::Temp->newdir();

chdir $dir or die "chdir failed: $!";

mkdir 'dir' or die "mkdir failed: $!";

SKIP: {
    skip 'The symlink function is unimplemented', 1 if !eval {
        symlink q{}, q{};    ## no critic (InputOutput::RequireCheckedSyscalls)
        1;
    };

    symlink 'dir', 'symlink' or die "symlink failed: $!";
}

$xtf = XT::Files->new( -config => undef );
is_deeply( [ $xtf->files ], [], 'no files are configured' );

$obj = XT::Files::Plugin::Files->new( xtf => $xtf );
isa_ok( $obj, 'XT::Files::Plugin::Files', 'new returned object' );

is( $obj->run( [ [ bin => 'non-existing-file' ], [ bin => 'dir' ], [ bin => 'symlink' ] ] ), undef, 'run returns undef' );

@files = $xtf->files;
is( scalar @files, 0, '... found 0 files' );

# allow File::Temp to remove the temporary dir
chdir $cwd;    ## no critic (InputOutput::RequireCheckedSyscalls)

#
done_testing();

exit 0;

sub _check_bin_file {
    my ($name) = @_;

    return sub {
        my ($file) = @_;

        is( $file->name, $name, "$name - correct name" );
        ok( !$file->is_module, "$name - !is_module" );
        ok( !$file->is_pod,    "$name - !is_pod" );
        ok( $file->is_script,  "$name - is_script" );
        ok( !$file->is_test,   "$name - !is_test" );

        return;
    };
}

sub _check_module_file {
    my ($name) = @_;

    return sub {
        my ($file) = @_;

        is( $file->name, $name, "$name - correct name" );
        ok( $file->is_module,  "$name - is_module" );
        ok( !$file->is_pod,    "$name - !is_pod" );
        ok( !$file->is_script, "$name - !is_script" );
        ok( !$file->is_test,   "$name - !is_test" );

        return;
    };
}

sub _check_pod_file {
    my ($name) = @_;

    return sub {
        my ($file) = @_;

        is( $file->name, $name, "$name - correct name" );
        ok( !$file->is_module, "$name - !is_module" );
        ok( $file->is_pod,     "$name - is_pod" );
        ok( !$file->is_script, "$name - !is_script" );
        ok( !$file->is_test,   "$name - !is_test" );

        return;
    };
}

sub _check_test_file {
    my ($name) = @_;

    return sub {
        my ($file) = @_;

        is( $file->name, $name, "$name - correct name" );
        ok( !$file->is_module, "$name - !is_module" );
        ok( !$file->is_pod,    "$name - !is_pod" );
        ok( $file->is_script,  "$name - is_script" );
        ok( $file->is_test,    "$name - is_test" );

        return;
    };
}
