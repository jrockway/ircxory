# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

package App::Ircxory::Robot::Model;
use strict;
use warnings;
use Carp;
use App::Ircxory::Config;
use App::Ircxory::Robot::Parser;
use List::MoreUtils qw(uniq);
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

=head2 karma_for($thing)

Returns the sum of points for C<$thing>

=cut

sub karma_for {
    my $schema = shift;
    my $thing  = shift;

    
    return $schema->resultset('Opinions')->
      search({ 'thing.thing' => lc $thing },
             { include_columns => 'thing.thing',
               join            => ['thing'],
             })->get_column('points')->sum || 0;
}


=head2 reasons_for($thing, [$good])

Returns a list of reasons why a certian thing was karama'd.  If
good is 1, then only ++s will be shown; if good is -1, then only --s
will be returned.

=cut

sub reasons_for {
    my $schema = shift;
    my $thing  = shift;
    my $good   = shift;
    
    my @points;
    if (defined $good && $good == -1) {
        @points = ('points' => {'<=', -1});
    }
    elsif (defined $good && $good == 1) {
        @points = ('points' => {'>=', 1});
    }
    
    my @reasons = $schema->resultset('Opinions')->
      search({ 'thing.thing' => lc $thing,
               reason        => {'<>', ""},
               @points,
             },
             { include_columns => 'thing.thing',
               join            => ['thing'],
             })->get_column('reason')->all;
    
    return uniq @reasons;
}

1;
