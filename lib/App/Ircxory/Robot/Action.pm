# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

package App::Ircxory::Robot::Action;
use strict;
use warnings;

use base 'Class::Accessor';
__PACKAGE__->mk_accessors(qw|nick channel word points reason|);

=head1 NAME

App::Ircxory::Robot::Action - encapsulate a decrement or increment

=head1 SYNOPSIS

    my $result = App::Ircxory::Robot::Action->
         new({ nick    => 'jrockway',  # me
               channel => '#jifty',    # "favorite" framework
               word    => 'catalyst',  # favorite framework
               points  => '1',         # +1 for ++, -1 for --
               reason  => 'modular',   # least likely comment to get me banned 
             });

=cut

1;
