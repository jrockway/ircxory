# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

package App::Ircxory::View::TD::People;
use strict;
use warnings;

use Template::Declare::Tags;
use App::Ircxory::View::TD::Wrapper;
use App::Ircxory::View::TD::Things;

use base 'Exporter';
our @EXPORT = qw/person/;

sub person(&) {
    my $person = shift->();
    a {
        attr { class => 'person',
               href  => uri_for '/person', $person
           };
        $person
    };
}

template 'people/one_person' => sub {
    my $person = c->stash->{person};
    wrapper {
        pair( title       => $person->name . q"'s Notables",
              left_title  => 'Ten favorite things',
              right_title => 'Ten favorite things to hate',
              left        => list_things(c->stash->{high}),
              right       => list_things(c->stash->{low}),
            );
        table {
            row {
                th { 'user' };
                th { 'nick' };
                th { 'host' };
            };
            my $nicks = c->stash->{nicknames};
            while (my $nick = $nicks->next) {
                row {
                    cell { $nick->username };
                    cell { person { $nick->nick } };
                    cell { $nick->host };
                };
            }
        }
    }
};

template 'people/everyone' => sub {
    my $people = c->stash->{people};
    wrapper {
        h2 { 'Everyone' };
        while (my $person = $people->next) {
            person { $person->name }
        }
    }
};

1;
