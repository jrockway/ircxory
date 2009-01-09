# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

package App::Ircxory::Controller::People;

use strict;
use warnings;
use base 'Catalyst::Controller';

sub everyone :Path :Args(0) {
    my ($self, $c) = @_;
    $c->stash->{people} = $c->model('DBIC::People');
}

sub one_person :Path :Args(1) {
    my ($self, $c, $name) = @_;
    
    # find who we're looking for
    my $person = $c->stash->{person} = $c->model('DBIC::People')->
      find($name, {key => 'nickname'});
    
    $c->detach('/error_404', [qq{No such person "$name"}]) unless $person;
    
    # get nicknames
    my $nicknames = $c->stash->{nicknames} = $person->nicknames;
    my $nickids = [$nicknames->get_column('nid')->all];
    my @cond    = ( { 'opinions.nid' => { -in => $nickids } },
                    { join => 'opinions' }
                  );
    
    # and do the search for things' scores
    my $t = $c->model('DBIC::Things');
    $c->stash->{high} = $t->highest_rated->search(@cond);
    $c->stash->{low}  = $t->lowest_rated->search(@cond);
}

1;
