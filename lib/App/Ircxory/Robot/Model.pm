# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

package App::Ircxory::Robot::Model;
use strict;
use warnings;
use Carp;
use App::Ircxory::Config;
use App::Ircxory::Robot::Parser;

use base 'App::Ircxory::Schema';

=head1 NAME

App::Ircxory::Robot::Model - interface to App::Ircxory::Schema for irc bot

=head1 SYNOPSIS

   my $schema   = App::Ircxory::Robot::Model->connect;
   my $action   = App::Ircxory::Robot::Action->new({ ... });
   my $recorder = $schema->get_recorder;
   $recorder->($action);

=head1 METHODS

=head2 connect

Connect to the DBIC schema (using the app config file for the DSN)

=cut

sub connect {
    my $invocant = shift;
    my $conf = App::Ircxory::Config->load || croak 'Failed to load config';
    my ($dsn, $user, $pass, $args) = @{$conf->{'Model::DBIC'}||[]};
    
    return $invocant->SUPER::connect($dsn, $user, $pass, $args);
}

=head2 get_recorder

Returns a subref that will call record with an action, given an
action.

=cut

sub get_recorder {
    my $self = shift;
    return sub {
        my $action = shift;
        $self->record($action);
    }
}


=head2 record($action)

Record a App::Ircxory::Robot::Action to the database

Insert an action into the database, creating people, nicknames, and
things if necessary.

=cut

sub record {
    my $self   = shift;
    my $action = shift;

    my $nickname = $self->_get_nickname(parse_nickname($action->who));
    my $thing    = $self->resultset('Things')->
      find_or_create({ thing => $action->word });

    my $channel  = $self->resultset('Channels')->
      find_or_create({ channel => $action->channel });
    
    return $self->resultset('Opinions')->
      create({ nickname  => $nickname,
               thing     => $thing,
               points    => $action->points,
               message   => $action->message,
               reason    => $action->reason,
               channel   => $channel,
             });
}

=head2 _get_nickname($nick, $user, $host)

Given nick/username/host, try to find a nickname object that matches.
If there isn't one, we'll create one and return that.

If the nickname isn't associated with a Person object yet, one will
be created.

=cut

sub _get_nickname {
    my $self = shift;
    my ($nick, $user, $host) = @_;
    
    my $nickname = $self->resultset('Nicknames')->
      find_or_create({ nick     => $nick, 
                       username => $user,
                       host     => $host,
                     });

    my $person = $nickname->person;
    if (!$person) {
        # TODO: be smarter about hostmasks etc.
        my $person = $self->resultset('People')->
          find_or_create({ name => $nick });
        $nickname->person($person);
        $nickname->update;
    }
    
    return $nickname;
}

1;
