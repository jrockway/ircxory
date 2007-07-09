# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

package App::Ircxory::View::TD::Root;
use strict;
use warnings;
use App::Ircxory::View::TD::Wrapper;
use App::Ircxory::View::TD::Pair;
use App::Ircxory::View::TD::Things;

template main => sub {
    wrapper {
        # best/worst
        pair( title       => 'By Score',
              left_title  => 'Ten Best Things',
              right_title => 'Ten Worst Things',
              left        => sub { list_things(c->stash->{top_ten}    )},
              right       => sub { list_things(c->stash->{bottom_ten} )},
            );

        # controversial
        pair( title       => 'By Controversy',
              left_title  => 'Ten Most Controversial Things',
              right_title => 'Ten Least Controversial Things',
              left       => sub { list_things(c->stash->{most_controversial})},
              right      => sub { list_things(c->stash->{least_controversial})},
            );

        # information
        p { 
            my $server   = c->config->{bot}{server};
            
            # what are we joined to?
            my @channels = @{c->config->{bot}{channels}||[]};
            my $last     = pop @channels if @channels > 1;
            my $channels = join ', ', @channels;
            $channels .= " or $last" if $last;
            
            <<"";
            Want to voice your opinion?  Connect to $server, join
            $channels, and start talking!  Ircxory will learn what you
            think.

        };
    };
}
