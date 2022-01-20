#!perl

use 5.006;
use strict;
use warnings;

use Test::Builder::Tester;
use Test::Fatal;
use Test::More 0.88;

use XT::Files;

local $ENV{XT_FILES_DEFAULT_CONFIG_FILE} = '../non existing file.txt';

chdir 'corpus/dist1' or die "chdir failed: $!";

is( XT::Files->_is_initialized, undef, 'singleton is not initialized' );

test_out(qr{[#]\Q [XT::Files] XT_FILES_DEFAULT_CONFIG_FILE points to non-existing default config file '../non existing file.txt'\E\n?});
my $output = exception { XT::Files->new };
test_test('correct error message');
like( $output, q{/XT_FILES_DEFAULT_CONFIG_FILE points to non-existing default config file '../non existing file.txt'/}, 'new dies if the config file cannot be read' );

#
done_testing();

exit 0;

# vim: ts=4 sts=4 sw=4 et: syntax=perl
