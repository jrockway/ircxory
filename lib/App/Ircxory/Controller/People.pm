# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

package App::Ircxory::Controller::People;

use strict;
use warnings;
use base 'Catalyst::Controller::BindLex';

sub everyone :Path :Args(0) {
    my ($self, $c) = @_;
    my $people :Stashed = $c->model('DBIC::People');
}

sub one_person :Path :Args(1) {
    my ($self, $c, $name) = @_;
    
    # find who we're looking for
    my $person :Stashed = $c->model('DBIC::People')->
      find($name, {key => 'nickname'});

    $c->detach('/error_404', [qq{No such person "$name"}]) unless $person;
    
    # get nicknames
    my $nicknames :Stashed = $person->nicknames;
    my $nickids = [$nicknames->get_column('nid')->all];
    my @cond    = ( { 'opinions.nid' => { -in => $nickids } },
                    { join => 'opinions' }
                  );
    
    # and do the search for things' scores
    my $t = $c->model('DBIC::Things');
    my $high :Stashed = $t->highest_rated->search(@cond);
    my $low  :Stashed = $t->lowest_rated->search(@cond);
}

1;
