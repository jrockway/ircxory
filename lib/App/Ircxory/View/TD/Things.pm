# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

package App::Ircxory::View::TD::Things;
use strict;
use warnings;
use App::Ircxory::View::TD::Wrapper;
use App::Ircxory::View::TD::People;
use App::Ircxory::View::TD::Pair;

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

sub list_reasons {
    my $opinions_ref = shift;
    if (!$opinions_ref->[0]){
        p { 'None!' };
        return;
    }

    foreach my $opinion (@$opinions_ref){
        div { attr { class => 'reason' };
              p {
                  span { attr { class => 'opinion_reason' };
                         $opinion->reason;
                     };
                  span { attr { class => 'written_by' };
                         person { $opinion->person };
                     };
              };
          };
    }
}

template 'things/one_thing' => sub {
    my $thing  = c->stash->{thing};
    my $points = c->stash->{points};
    my $ups    = c->stash->{ups};
    my $downs  = c->stash->{downs};
    
    wrapper {
        h2 { "Information on $thing" };
        p { 
            outs("$thing has karma of ");
            score { $points };
            outs(" from being upmodded ");
            score { $ups };
            outs(" times and downmodded ");
            span { attr { class => 'negative_score' };
                   $downs 
               };
            outs(" times.");
        };
        if (c->stash->{person}) {
            p {
                person { c->stash->{person}->name };
                outs(' is also a person!');
            };
        }

        pair( left_title  => "Reasons why $thing is loved",
              right_title => "Reasons why $thing is hated",
              left        => sub { list_reasons(c->stash->{up_reasons}) },
              right       => sub { list_reasons(c->stash->{down_reasons}) },
              width       => '50em',
            );
        div { attr { class => 'pair', style => 'width: 50em' };
              div { attr { class => 'box', 
                           style => 'padding-left: 13em; padding-right: 13em;',
                       };
                    my $neutral_reasons = c->stash->{neutral_reasons};
                    if ($neutral_reasons->[0]) {
                        h3 {
                            outs("Reasons why $thing is meh");
                            list_reasons($neutral_reasons);
                        }
                    }
                }
          };
    };
};

1;
