# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

package App::Ircxory::Robot::Query::ReasonFor;
use strict;
use warnings;

use base 'App::Ircxory::Robot::Query';

__PACKAGE__->mk_accessors(qw/target direction/);

=head1 NAME

App::Ircxory::Robot::Query::ReasonFor - user wants to what reasons have been given for karmas

=cut

1;
