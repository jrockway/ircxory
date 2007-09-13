# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

package App::Ircxory::View::TD::Things;
use strict;
use warnings;

BEGIN {
    use base 'Exporter';
    our @EXPORT = qw/list_things controversy_list_things thing score/;
}

use Template::Declare::Tags;
use App::Ircxory::View::TD::Wrapper;
use App::Ircxory::View::TD::People;
use App::Ircxory::View::TD::Pair;

my %EMOTION_FOR = ( up   => 'loved',
                    down => 'hated',
                  );

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
                score { $thing->ups };
                score { -$thing->downs };
            }
        }
    }
}

sub list_reasons {
    my ($direction, $thing) = @_;
    my $opinions_ref = c->stash->{"${direction}_reasons"};

    div { 
        attr { class => 'paired_thing_data' };
        if (!$opinions_ref->[0] && !){
            p { 'None!' };
        }
        else {
            # karma events with reasons
            foreach my $opinion (@$opinions_ref){
                div { 
                    attr { class => 'reason' };
                    p {
                        span { 
                            attr { class => 'opinion_reason' };
                            $opinion->reason;
                        };
                        span { 
                            attr { class => 'written_by' };
                            person(sub{ $opinion->person });
                        }
                    }
                }
            }
        }
        
        # list of people that karma'd without giving a reason
        my @reasonless = @{c->stash->{"${direction}_reasonless"}||[]};
        if (@reasonless) {
            p {
                attr { class => 'reasonless_voters' };
                outs("The following people $EMOTION_FOR{$direction} ".
                     "$thing for no reason: ");
                person(sub{$_}) for @reasonless;
            };
        }
    }
}

template 'things/all_things' => sub {
    wrapper {
        h2 { 'Every thing' };
        ul {
            while (my $row = c->stash->{everything}->next) {
                thing { $row->thing };
                score { $row->total_points };
            }
        }
    }
};

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
                person(sub { c->stash->{person}->name });
                outs(' is also a person!');
            };
        }
        
        pair( left_title  => "Reasons why $thing is loved",
              right_title => "Reasons why $thing is hated",
              left        => sub { list_reasons('up', $thing) },
              right       => sub { list_reasons('down', $thing) },
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
                        };
                        list_reasons($neutral_reasons);
                    }
                }
          };
    };
};

1;
