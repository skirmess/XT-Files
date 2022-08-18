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

package XT::Files::Plugin::Default;

our $VERSION = '0.002';

use parent 'XT::Files::Plugin';

sub run {
    my ( $self, $args ) = @_;

    my $dirs     = 1;
    my $excludes = 1;

  ARG:
    for my $arg ( @{$args} ) {
        my ( $key, $value ) = @{$arg};

        if ( $key eq 'dirs' ) {
            $dirs = !!$value;
            next ARG;
        }

        if ( $key eq 'excludes' ) {
            $excludes = !!$value;
            next ARG;
        }

        $self->log_fatal("Invalid configuration option '$key = $value' for plugin 'Default'");
    }

    my $xtf = $self->xtf;

    if ($excludes) {
        $xtf->plugin( 'Excludes', undef, [ map { [ 'exclude' => $_ ] } (qw([.]swp$ [.]bak$ ~$)) ] );
    }

    if ($dirs) {
        $xtf->plugin(
            'Dirs', undef,
            [
                [ bin    => 'bin' ],
                [ bin    => 'script' ],
                [ module => 'lib' ],
            ],
        );
    }

    return;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

XT::Files::Plugin::Default - plugin with default configuration

=head1 VERSION

Version 0.002

=head1 SYNOPSIS

In the L<XT::Files> config file:

    [Default]
    dirs = 1
    excludes = 1

=head1 DESCRIPTION

This plugin contains the default configuration for L<XT::Files>. If no
configuration file is present for C<XT::Files>, this plugin is loaded.
The plugin can also be loaded from the config file to extend upon its config.

The default configuration configures the following exclude regexes

    [.]swp$
    [.]bak$
    ~$

and adds files from the following directories

    bin
    script
    lib

The C<bin> and C<script> directory are processed as type bin directory and
C<lib> as type module.

The C<dirs> and the C<excludes> arguments can be used to disable the
configuration of the default excludes or directories. This can be useful if
you use your own L<XT::Files> config file but want to only use one of the
two defaults.

=head1 USAGE

=head2 new

Inherited from L<XT::Files::Plugin>.

=head2 run

The C<run> method should not be run directly. Use the C<plugin> call from
L<XT::Files>

=head1 SEE ALSO

L<XT::Files>, L<XT::Files::Plugin::Dirs>, L<XT::Files::Plugin::Excludes>

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
