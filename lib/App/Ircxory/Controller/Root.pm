# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

package App::Ircxory::Controller::Root;
use strict;
use warnings;

use base 'Catalyst::Controller';
__PACKAGE__->config(namespace => q{});

sub main : Path Args(0) {
    my ($self, $c) = @_;
    
    # highest/lowest by score
    $c->stash(top_ten    => scalar $c->model('DBIC::Things')->highest_rated);
    $c->stash(bottom_ten => scalar $c->model('DBIC::Things')->lowest_rated );
    
    # controversy
    $c->stash(most_controversial => 
              scalar $c->model('DBIC::Things')->most_controversial);
    $c->stash(least_controversial => 
              scalar $c->model('DBIC::Things')->least_controversial);
}

sub error_404 :Private {
    my ($self, $c, $reason) = @_;
    $reason ||= 'Not found';
    
    $c->response->status(404);
    
    $c->stash(reason   => $reason);
    $c->stash(template => 'error_404');
}

sub end : ActionClass(RenderView) {
    my ($self, $c) = @_;
    $c->response->content_type('application/xhtml+xml; charset=utf-8')
      if $c->response->content_type =~ /html/;
}

=head1 NAME

App::Ircxory::Controller::Root - root controller for ircxory

=head1 ACTIONS

=head2 main

The main page, available at C</>.

=head2 end

Head over to TT to render the page.

=head1 DESCRIPTION

Shows the main page.

=cut

1;
