# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

package App::Ircxory::Controller::Things;
use strict;
use warnings;

use base 'Catalyst::Controller';

sub one_thing :Path Args(1) {
    my ($self, $c, $thing) = @_;
    my $m = $c->model('DBIC');

    # aggregates
    $c->stash(template => 'thing.tt2');
    $c->stash(thing    => $thing);
    $c->stash(points   => $m->karma_for($thing));
    $c->stash(ups      => $m->karma_for($thing, 1));
    $c->stash(downs    => $m->karma_for($thing, -1));

    # detailed reasons
    my @reasons = $m->detailed_reasons_for($thing);
    my @up_r = grep { $_->[2] >  0 } @reasons;
    my @dn_r = grep { $_->[2] <  0 } @reasons;
    my @nu_r = grep { $_->[2] == 0 } @reasons;
    
    $c->stash(up_reasons      => \@up_r);
    $c->stash(down_reasons    => \@dn_r);
    $c->stash(neutral_reasons => \@nu_r);
    
}

1;
