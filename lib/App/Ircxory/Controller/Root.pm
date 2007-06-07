# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

package App::Ircxory::Controller::Root;
use strict;
use warnings;

use base 'Catalyst::Controller';
__PACKAGE__->config(namespace => q{});

sub main : Path {
    my ($self, $c, @args) = @_;
    $c->stash(template => 'index.tt2');
}

sub end : ActionClass(RenderView) {
    my ($self, $c) = @_;
    $c->response->content_type('application/xhtml+xml; charset=utf-8');
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
