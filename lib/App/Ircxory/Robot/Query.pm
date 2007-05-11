# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

package App::Ircxory::Robot::Query;
use strict;
use warnings;

use base 'Class::Accessor';

__PACKAGE__->mk_accessors(qw/requestor channel/);

=head1 NAME

App::Ircxory::Robot::Query - event indicating that the user requested
some information from the bot

=cut

1;
