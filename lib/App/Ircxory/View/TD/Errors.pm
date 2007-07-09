# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

package App::Ircxory::View::TD::Errors;
use strict;
use warnings;

use App::Ircxory::View::TD::Wrapper;

template 'error_404' => sub {
    my $reason = c->stash->{reason};
    wrapper {
        h2 { '404 Not Found' };
        p { $reason } if $reason;
        a { 
            attr { href => uri_for '/' };
            'Go home'
        };
        outs('?');
    }
};

1;
