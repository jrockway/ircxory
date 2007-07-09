# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

package App::Ircxory::View::TD::Pair;
use strict;
use warnings;
use base 'Exporter';
our @EXPORT = qw/pair/;

sub pair {
    my $args = {@_};
    my $width = $args->{width};
    my $left  = $args->{left}  || die 'need lhs';
    my $right = $args->{right} || die 'need rhs';
    my $title = $args->{title};
    my $lt    = $args->{left_title};
    my $rt    = $args->{right_title};
    
    smart_tag_wrapper {
        div {
            attr { my @attrs = (class => 'pair clearfix');
                   push @attrs, (style => "width: $width")
                     if $width;
                   @attrs
               };
            h2 {
                $title
            };
            div {
                attr { class => 'box left' };
                h3 { $lt };
                $left->();
            };
            div {
                attr { class => 'box right' };
                h3 { $rt };
                $right->();
            };
            br { attr { class => 'clear' } };
        };
    };
};

1;
