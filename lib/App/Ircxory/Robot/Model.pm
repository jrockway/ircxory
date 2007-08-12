# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

package App::Ircxory::Robot::Model;
use strict;
use warnings;
use Carp;
use App::Ircxory::Config;
use List::MoreUtils qw(uniq);
use base 'App::Ircxory::Schema';

=head1 NAME

App::Ircxory::Robot::Model - interface to App::Ircxory::Schema for irc bot

=head1 SYNOPSIS

   my $schema = App::Ircxory::Robot::Model->connect;

This connect will use the  Ircxory configuration file to determine the
location of the database.

=head1 METHODS

=head2 connect

Connect to the DBIC schema (using the app config file for the DSN)

=cut

sub connect {
    my $invocant = shift;
    my $conf = App::Ircxory::Config->load || croak 'Failed to load config';
    my ($dsn, $user, $pass, $args) = @{$conf->{'Model::DBIC'}{connect_info}||[]};
    
    return $invocant->SUPER::connect($dsn, $user, $pass, $args);
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


=head1 SEE ALSO

L<App::Ircxory::Schema>

=cut

1;
