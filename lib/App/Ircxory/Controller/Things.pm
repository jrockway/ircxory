# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

package App::Ircxory::Controller::Things;
use strict;
use warnings;

use base 'Catalyst::Controller';

sub all_things :Path Args(0) {
    my ($self, $c) = @_;
    $c->stash(everything => 
              scalar $c->model('DBIC::Things')->
                  everything({},
                             { order_by => 'SUM(opinions.points) DESC' }
                            )
             );
}

sub one_thing :Path Args(1) {
    my ($self, $c, $thing) = @_;
    my $m = $c->model('DBIC');
    
    # aggregates
    $c->stash(thing    => $thing);
    $c->stash(points   => $m->karma_for($thing));
    $c->stash(ups      => $m->karma_for($thing, 1));
    $c->stash(downs    => $m->karma_for($thing, -1));
    $c->stash(person   => 
              scalar $m->resultset('People')->find({ name => $thing},
                                                   { key => 'nickname' })
             );
    
    # detailed reasons
    my @reasons = $c->model('DBIC::Things')->reasons_for($thing);
    my @up_r = grep { $_->points >  0 } @reasons;
    my @dn_r = grep { $_->points <  0 } @reasons;
    my @nu_r = grep { $_->points == 0 } @reasons;
    
    $c->stash(up_reasons      => \@up_r);
    $c->stash(down_reasons    => \@dn_r);
    $c->stash(neutral_reasons => \@nu_r);

    # reasonless voters
    my ($ups, $downs) = 
      $c->model('DBIC::Things')->
        search({ thing => $thing })->
          no_comment;
    $c->stash('up_reasonless' => $ups);
    $c->stash('down_reasonless' => $downs);
}

1;
