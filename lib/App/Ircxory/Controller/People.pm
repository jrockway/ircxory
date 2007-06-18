# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

package App::Ircxory::Controller::People;
use strict;
use warnings;


use base 'Catalyst::Controller::BindLex';

sub one_person :Path :Args(1) {
    my ($self, $c, $name) = @_;

    my $person :Stashed = $c->model('DBIC::People')->
      find($name, {key => 'nickname'});
    
    $c->stash(template => 'person.tt2');
    
    my @high :Stashed = 
      $person->nicknames->search_related('opinions')->highest_rated;
    my @low  :Stashed = 
      $person->nicknames->search_related('opinions')->lowest_rated;
    
}

1;
