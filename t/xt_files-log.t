#!perl

use 5.006;
use strict;
use warnings;

use Test::Builder::Tester;
use Test::More 0.88;

use XT::Files;

delete $ENV{XT_FILES_DEFAULT_CONFIG_FILE};

chdir 'corpus/dist1' or die "chdir failed: $!";

my $config = "\t# hello\n    ; world\n \t \t :version \t =\t0.001 \t \t ";
my $obj    = XT::Files->new( -config => \$config );
isa_ok( $obj, 'XT::Files', 'new returned object' );

test_out(q{# [XT::Files] this is a test 103});
$obj->log('this is a test 103');
test_test('correct error message');

#
done_testing();

exit 0;

# vim: ts=4 sts=4 sw=4 et: syntax=perl
