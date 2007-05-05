# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

package App::Ircxory::Robot::Action;
use strict;
use warnings;

use base 'Class::Accessor';
__PACKAGE__->mk_accessors(qw|who channel word points reason message|);

=head1 NAME

App::Ircxory::Robot::Action - encapsulate a decrement or increment

=head1 SYNOPSIS

    my $result = App::Ircxory::Robot::Action->
         new({ who     => 'jrockway!~jon@foo.jrock.us',
               channel => '#jifty', 
               word    => 'catalyst',
               points  => '1',       
               reason  => 'actually works', 
               message => 'catalyst++  # actually works',
             });

=cut

1;
