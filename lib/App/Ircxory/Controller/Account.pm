# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

package App::Ircxory::Controller::Account;
use strict;
use warnings;
use base 'Catalyst::Controller';

sub login :Global :Args(0) {
    my ($self, $c) = @_;
};

sub logout :Global :Args(0) {
    my ($self, $c) = @_;
}

1;
