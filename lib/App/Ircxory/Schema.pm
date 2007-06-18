package App::Ircxory::Schema;

use strict;
use warnings;
use App::Ircxory::Robot::Parser;
use Carp;

use base 'DBIx::Class::Schema';
__PACKAGE__->load_classes;

=head1 NAME

App::Ircxory::Schema - database for Ircxory

=head1 SYNOPSIS

    my $schema = App::Ircxory::Schema->connect

    # record an "opinion"
    my $action = App::Ircxory::Robot::Action->new({...});
    $schema->record($action);

=head1 METHODS

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
      create({ nickname => $nickname,
               thing    => $thing,
               points   => $action->points,
               message  => $action->message,
               reason   => $action->reason,
               channel  => $channel,
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

=head2 karma_for($thing [, $direction])

Returns the sum of points for C<$thing>.  If C<$direction> is
specified, the number of times $thing was modded in $direction is
returned.

=cut

sub karma_for {
    my $schema = shift;
    my $thing  = shift;
    my $dir    = shift;
    
    my @points;
    if (defined $dir && $dir == -1) {
        @points = ('points' => {'<=', -1});
    }
    elsif (defined $dir && $dir == 1) {
        @points = ('points' => {'>=', 1});
    }
    elsif (defined $dir && $dir == 0) {
        @points = ('points' => {'==', 0});
    }
    
    my $col = 
      $schema->resultset('Opinions')->
        search({ 'thing.thing' => lc $thing,
                 @points,
               },
               { include_columns => 'thing.thing',
                 join            => ['thing'],
               })->get_column('points');
    
    if (defined $dir) {
        return $col->func('count');
    }
    return $col->sum || 0;
}

1;

