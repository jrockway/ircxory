# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

package App::Ircxory::View::TD::People;
use strict;
use warnings;

use App::Ircxory::View::TD::Wrapper;

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

1;
