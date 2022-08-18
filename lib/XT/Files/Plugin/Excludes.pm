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

package XT::Files::Plugin::Excludes;

our $VERSION = '0.002';

use parent 'XT::Files::Plugin';

sub run {
    my ( $self, $args ) = @_;

    my $xtf = $self->xtf;

  ARG:
    for my $arg ( @{$args} ) {
        my ( $key, $value ) = @{$arg};

        if ( $key eq 'exclude' ) {
            $xtf->exclude($value);
            next ARG;
        }

        $self->log_fatal("Invalid configuration option '$key = $value' for plugin 'Excludes'");
    }

    return;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

XT::Files::Plugin::Excludes - plugin to configure excludes

=head1 VERSION

Version 0.002

=head1 SYNOPSIS

In the L<XT::Files> config file:

    [Excluded]
    exclude = [.]old$

=head1 DESCRIPTION

Configure excludes for L<XT::Files>. Excludes are regexes that are matched
against the base name of found files and if the file name matches the file
is not tested.

Use this to exclude backup files or temporary files from your editor.

The C<exclude> option can be used multiple times to add multiple excludes.

=head1 USAGE

=head2 new

Inherited from L<XT::Files::Plugin>.

=head2 run

The C<run> method should not be run directly. Use the C<plugin> call from
L<XT::Files>

=head1 SEE ALSO

L<XT::Files>, L<XT::Files::Plugin>, L<XT::Files::Plugin::Default>

=head1 SUPPORT

=head2 Bugs / Feature Requests

Please report any bugs or feature requests through the issue tracker
at L<https://github.com/skirmess/XT-Files/issues>.
You will be notified automatically of any progress on your issue.

=head2 Source Code

This is open source software. The code repository is available for
public review and contribution under the terms of the license.

L<https://github.com/skirmess/XT-Files>

  git clone https://github.com/skirmess/XT-Files.git

=head1 AUTHOR

Sven Kirmess <sven.kirmess@kzone.ch>

=cut
