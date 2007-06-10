# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

package App::Ircxory::Robot::Model;
use strict;
use warnings;
use Carp;
use App::Ircxory::Config;
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
    my ($dsn, $user, $pass, $args) = @{$conf->{'Model::DBIC'}||[]};
    
    return $invocant->SUPER::connect($dsn, $user, $pass, $args);
}

=head1 SEE ALSO

L<App::Ircxory::Schema>

=cut

1;
