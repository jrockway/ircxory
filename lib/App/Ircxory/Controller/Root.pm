# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

package App::Ircxory::Controller::Root;
use strict;
use warnings;

use base 'Catalyst::Controller';
__PACKAGE__->config(namespace => q{});

sub index : Private {
    my ($self, $c, @args) = @_;
    $c->response->body("It works.");
}

=head1 NAME

App::Ircxory::Controller::Root - root controller for ircxory

=head1 ACTIONS

=head2 index

The main page, available at C</>.

=head1 DESCRIPTION

Shows the main page.

=cut

1;
