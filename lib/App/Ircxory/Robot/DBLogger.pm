# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

package App::Ircxory::Robot::DBLogger;
use strict;
use warnings;
use Carp;
use App::Ircxory::Config;

use base 'App::Ircxory::Schema';

=head1 NAME

App::Ircxory::Robot::DBLogger - log C<App::Ircxory::Robot::Action>s to a DBIC database

=head1 METHODS

=head2 connect

Connect to the DBIC schema

=head2 record($action)

Record a App::Ircxory::Robot::Action to the database

=head2 get_recorder

Returns a subref that will call record with an action, given an
action.

=cut

sub connect {
    my $invocant = shift;
    my $conf = App::Ircxory::Config->load || croak 'Failed to load config';
    my ($dsn, $user, $pass, $args) = @{$conf->{'Model::DBIC'}||[]};
    
    return $invocant->SUPER::connect($dsn, $user, $pass, $args);
}

sub record {
    my $self   = shift;
    my $action = shift;

    warn "logging action: $action";
}

sub get_recorder {
    my $self = shift;
    return sub {
        my $action = shift;
        $self->record($action);
    }
}

1;
