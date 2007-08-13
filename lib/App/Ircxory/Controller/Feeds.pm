# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

package App::Ircxory::Controller::Feeds;
use strict;
use warnings;

use base 'Catalyst::Controller';

sub actions :Path('actions.xml') :Args(0) {
    my ($self, $c) = @_;

    my $recent = $c->model('DBIC::Opinions')->
      search({}, { order_by => 'oid DESC', rows => 30 })->page(1);
    
    $c->stash->{feed_entries} = [$recent->all];
    $c->detach($c->view('Atom'));
}

1;
