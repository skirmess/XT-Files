package XT::Files::Plugin;

use 5.006;
use strict;
use warnings;

our $VERSION = '0.002';

use Carp         ();
use Scalar::Util ();

use XT::Files::Logger;

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
    if ( !defined $name ) {
        $name = $class;
    }

    my $self = bless {
        name    => $name,
        xtf     => $args->{xtf},
        _logger => XT::Files::Logger->new( name => $name ),
    }, $class;

    my $xtf = $self->xtf;
    Carp::croak 'xtf attribute required'             if !defined $xtf;
    Carp::croak q{'xtf' is not of class 'XT::Files'} if !defined Scalar::Util::blessed($xtf) || !$xtf->isa('XT::Files');

    return $self;
}

sub log {    ## no critic (Subroutines::ProhibitBuiltinHomonyms)
    return shift->{_logger}->log(@_);
}

sub log_debug {
    return shift->{_logger}->log_debug(@_);
}

sub log_fatal {
    my $self = shift;

    my $package = __PACKAGE__;
    local $Carp::CarpInternal{$package} = 1;    ## no critic (Variables::ProhibitPackageVars)

    return $self->{_logger}->log_fatal(@_);
}

sub name {
    my ($self) = @_;

    return $self->{name};
}

sub xtf {
    my ($self) = @_;

    return $self->{xtf};
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

XT::Files::Plugin - base class for XT::Files plugins

=head1 VERSION

Version 0.002

=head1 SYNOPSIS

    my $obj = XT::Files::Plugin->new( xtf => XT_FILES_OBJECT );

    $obj->xtf; # returns XT_FILES_OBJECT

=head1 DESCRIPTION

This is the parent class for all L<XT::Files> plugins. There should never be
a reason to instantiate this class directly. To write your own plugin, use
this class as your parent.

    use parent 'XT::Files::Plugin';

Your plugin then must implement a C<run> method which takes a single
argument, a reference to an array of array references. These arrays contain
the configuration that is forwarded from the config file to your plugin.
The following config file entry

    [YourPlugin]
    key 1 = value 1
    key 2 = value 2a
    key 2 = value 2b

would result in your plugin being called like so

    $obj->run( [
        [ 'key 1' => 'value 1' ],
        [ 'key 2' => 'value 2a' ],
        [ 'key 2' => 'value 2b'],
    ] );

=head1 USAGE

=head2 new

Requires the C<xtf> argument.

=head2 log, log_debug, log_fatal

Call the method with the same name of this plugins L<XT::Files::Logger>
object.

=head2 name

Returns the name of the plugin.

=head2 xtf

Returns the L<XT::Files> object that was passed with C<new>.

=head1 SEE ALSO

L<XT::Files>

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

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2018-2022 by Sven Kirmess.

This is free software, licensed under:

  The (two-clause) FreeBSD License

=cut

# vim: ts=4 sts=4 sw=4 et: syntax=perl
