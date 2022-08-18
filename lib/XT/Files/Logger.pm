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

package XT::Files::Logger;

our $VERSION = '0.002';

use Carp          ();
use Scalar::Util  ();
use Test::Builder ();

sub new {
    my $class = shift;

    my $args;
    if (   @_ == 1
        && defined Scalar::Util::reftype $_[0]
        && Scalar::Util::reftype $_[0] eq Scalar::Util::reftype {} )
    {
        $args = $_[0];
    }
    elsif ( @_ % 2 == 0 ) {
        $args = {@_};
    }
    else {
        Carp::croak "$class->new() got an odd number of arguments";
    }

    my $name = $args->{name};
    Carp::croak 'name attribute required' if !defined $name;

    my $self = bless {
        _name => $name,
    }, $class;

    return $self;
}

sub log {    ## no critic (Subroutines::ProhibitBuiltinHomonyms)
    my ( $self, $msg ) = @_;

    # ->diag is printed during 'prove'
    # ->note is printed during 'prove -v'
    Test::Builder->new->note("[$self->{_name}] $msg");

    return;
}

sub log_debug {
    my ( $self, $msg ) = @_;

    return if !$ENV{XT_FILES_DEBUG};

    $self->log($msg);

    return;
}

sub log_fatal {
    my ( $self, $msg ) = @_;

    $self->log($msg);

    my $package = __PACKAGE__;
    local $Carp::CarpInternal{$package} = 1;    ## no critic (Variables::ProhibitPackageVars)

    Carp::confess("[$self->{_name}] $msg");
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

XT::Files::Logger - logger object for XT::Files

=head1 VERSION

Version 0.002

=head1 SYNOPSIS

    my $logger = XT::Files::Logger->new( name => 'plugin name' );

    $logger->log($message);
    $logger->log_debug($message);
    $logger->log_fatal($message);

=head1 DESCRIPTION

The logger used by all L<XT::Files> classes.

=head1 USAGE

=head2 log ( MESSAGE )

Logs the message with L<Test::Builder>s C<note> method. This should be used
for all output instead of just printing it to work nicely with the Perl
testing environment.

=head2 log_debug ( MESSAGE )

Logs the message with C<log> but only if the environment variable
C<XT_FILES_DEBUG> is set and true.

=head2 log_fatal ( MESSAGE )

Logs the message with C<log>, then dies with L<Carp>s C<confess>.

=head1 SEE ALSO

L<XT::Files>, L<Carp>, L<Test::Builder>

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
