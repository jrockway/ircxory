# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

package App::Ircxory::View::TD::Things;
use strict;
use warnings;
use App::Ircxory::View::TD::Wrapper;

use base 'Exporter';
our @EXPORT = qw/list_things thing score/;

sub thing(&) {
    my $thing = shift->();
    a { attr { class => 'thing', href => uri_for('/things', $thing)};
        $thing;
    }
}

sub score(&) {
    my $score = shift->();
    my $class = $score > 0 ? 'positive' : 'negative';
    span { attr { class => "${class}_score" }; $score };
}

sub list_things($) {
    my $things = shift;
    ul {
        while (my $thing = $things->next) {
            li { # thing 42
                thing { $thing->thing };
                score { $thing->total_points };
            }
        }
    }
}

sub controversy_list_things($) {
    my $things = shift;
    ul {
        while (my $thing = $things->next) {
            li { # thing 42 (+43,-1)
                thing { $thing->thing };
                score { $thing->total_points };
                outs('(');
                score { $thing->ups };
                outs(',');
                score { $thing->downs };
                outs(')');
            }
        }
    }
}

1;
