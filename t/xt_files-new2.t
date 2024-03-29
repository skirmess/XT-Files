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

use File::stat;
use File::Temp;

use Cwd            ();
use File::Basename ();
use File::Spec     ();
use lib File::Spec->catdir( File::Basename::dirname( Cwd::abs_path __FILE__ ), 'lib' );

use Local::Test::Exception qw(exception);

use XT::Files;

delete $ENV{XT_FILES_DEFAULT_CONFIG_FILE};

note('new with config');

chdir 'corpus/dist1' or die "chdir failed: $!";

is( XT::Files->_is_initialized, undef, 'singleton is not initialized' );

my $output = exception { XT::Files->new(77) };
like( $output, qr{\QXT::Files->new() got an odd number of arguments\E}, 'new dies with an odd number of arguments' );

test_out(qr{[#]\Q [XT::Files] Cannot read file 'non existing file.txt': \E.*\n?});
$output = exception { XT::Files->new( -config => 'non existing file.txt' ) };
test_test('correct error message');
like( $output, q{/Cannot read file 'non existing file.txt': /}, 'new dies if the config file cannot be read' );

my $config = 'hello';
test_out('# [XT::Files] Syntax error in config on line 1');
$output = exception { XT::Files->new( -config => \$config ) };
test_test('correct error message');
like( $output, '/Syntax error in config on line 1/', 'new dies on invalid config' );

$config = '=hello';
test_out('# [XT::Files] Syntax error in config on line 1');
$output = exception { XT::Files->new( { -config => \$config } ) };
test_test('correct error message');
like( $output, '/Syntax error in config on line 1/', 'new dies on invalid config' );

$config = 'hello=';
test_out('# [XT::Files] Syntax error in config on line 1');
$output = exception { XT::Files->new( -config => \$config ) };
test_test('correct error message');
like( $output, '/Syntax error in config on line 1/', 'new dies on invalid config' );

$config = ':version = 99999999';
test_out(qr{[#]\Q [XT::Files] XT::Files version 99999999 required--this is only version \E.*\n?});
$output = exception { XT::Files->new( -config => \$config ) };
test_test('correct error message');
like( $output, '/XT::Files version 99999999 required--this is only version /', '... dies if the :version is not ok' );

$config = ':version=1=2 ';
test_out(q{# [XT::Files] Not a valid version '1=2'});
$output = exception { XT::Files->new( -config => \$config ) };
test_test('correct error message');
like( $output, qr{Not a valid version '1=2'}, '... correctly splits on first equal sign' );

$config = "\t# hello\n    ; world\n \t \t :version \t =\t0.001 \t \t ";
isa_ok( XT::Files->new( -config => \$config ), 'XT::Files', 'new returned object' );

$config = "\t[=Local::Test";
test_out(q{# [XT::Files] Syntax error in config on line 1});
$output = exception { XT::Files->new( -config => \$config ) };
test_test('correct error message');
like( $output, '/Syntax error in config on line 1/', '... dies if the plugin section is corrupt' );

#
lib->import('xt/lib');

my $tempdir          = File::Temp->newdir();
my $report_file_base = "$tempdir/report_" . __LINE__;
local $ENV{REPORT_FILE_BASE} = $report_file_base;

$config = "\t[=Local::Test] ";
isa_ok( XT::Files->new( -config => \$config ), 'XT::Files', 'new returned object' );

my $st = stat "${report_file_base}.new";
ok( defined $st, '... new was run' );
if ( defined $st ) {
    is( $st->size, 0, '... without arguments' );
}

$st = stat "${report_file_base}.run";
ok( defined $st, '... run was run' );
if ( defined $st ) {
    is( $st->size, 0, '... without arguments' );
}

#
$report_file_base = "$tempdir/report_" . __LINE__;
local $ENV{REPORT_FILE_BASE} = $report_file_base;

$config = <<'CONFIG';

[=Local::Test]
:a = b
e = f
:version = 0.001
:c d = hello world
g h = HELLO WORLD
CONFIG

isa_ok( XT::Files->new( -config => \$config ), 'XT::Files', 'new returned object' );

$st = stat "${report_file_base}.new";
ok( defined $st, '... new was run' );
if ( defined $st ) {
    is( $st->size, 0, '... without arguments' );
}

my $rc = open my $fh, '<', "${report_file_base}.run";
ok( $rc, '... run was run' );
if ($rc) {
    my @lines = <$fh>;
    close $fh or die "read failed: $!";
    chomp @lines;
    is_deeply( \@lines, [ ':a=b', 'e=f', ':c d=hello world', 'g h=HELLO WORLD', ], '... with the correct arguments' );
}

#
$report_file_base = "$tempdir/report_" . __LINE__;
local $ENV{REPORT_FILE_BASE} = $report_file_base;

$config = <<'CONFIG';
[=Local::Test]
:a = b
e = f
:version = 0.001
:c d = hello world
g h = HELLO WORLD
[=Local::Test]
:version = 0.001
x = y
:v = w
CONFIG

isa_ok( XT::Files->new( -config => \$config ), 'XT::Files', 'new returned object' );

$st = stat "${report_file_base}.new";
ok( defined $st, '... new was run' );
if ( defined $st ) {
    is( $st->size, 0, '... without arguments' );
}

$rc = open $fh, '<', "${report_file_base}.run";
ok( $rc, '... run was run' );
if ($rc) {
    my @lines = <$fh>;
    close $fh or die "read failed: $!";
    chomp @lines;
    is_deeply( \@lines, [ 'x=y', ':v=w', ], '... with the correct arguments' );
}

#
done_testing();

exit 0;
