#!perl

use 5.006;
use strict;
use warnings;

use Test::Builder::Tester;
use Test::Fatal;
use Test::More 0.88;

use XT::Files;

delete $ENV{XT_FILES_DEFAULT_CONFIG_FILE};

chdir 'corpus/dist1' or die "chdir failed: $!";

is( XT::Files->_is_initialized, undef, 'singleton is not initialized' );

my $obj = XT::Files->new( -config => undef );
isa_ok( $obj, 'XT::Files', 'new returned object' );

test_out(qr{[#]\Q [XT::Files] Cannot read file 'non existing file.txt': \E.*\n?});
my $output = exception { $obj->_load_config('non existing file.txt') };
test_test('correct error message');
like( $output, q{/Cannot read file 'non existing file.txt': /}, '_load_config dies if the config file cannot be read' );

#
done_testing();

exit 0;

# vim: ts=4 sts=4 sw=4 et: syntax=perl
