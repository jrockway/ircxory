#!/usr/bin/env perl
# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

use strict;
use warnings;
use Test::More;
use App::Ircxory::Robot::Action;
use App::Ircxory::Robot::Parser;
use Readonly;
use App::Ircxory::Robot::Query::ReasonFor;
use Data::Dumper;

use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init($FATAL);

Readonly my $USER       => 'me!~me@my/machine';
Readonly my $CHAN       => '#foo.bar';
Readonly my $BOT        => 'foobot';
my $BOTINFO = { nick => $BOT};

my %COMMANDS = (
                'foobot: reason why jrockway is disliked?' 
                => mk_rq('jrockway', -1),
                'foobot: reasons why dongs are disliked?'
                => mk_rq('dongs', -1),
                'foobot: reason why jrockway is liked?' 
                => mk_rq('jrockway', 1),
                'foobot: reasons why dongs are liked?'
                => mk_rq('dongs', 1),
                'foobot: reason why jrockway is liked' 
                => mk_rq('jrockway', 1),
                'foobot: reasons why dongs are liked'
                => mk_rq('dongs', 1),
                'reason why jrockway is liked' 
                => undef,
                'foobot: reasons why dongs are licked?'
                => undef,
                'la la la'
                => undef,
               );

plan tests => (scalar keys %COMMANDS);

while (my ($k, $v) = each %COMMANDS) {
    no warnings 'uninitialized';
    my $got = parse($BOTINFO, $USER, $k, $CHAN);
    my $exp = $v;

    my $ok = 0;
    if (defined $exp && defined $got) {
        $ok = 1;
        $ok &&= $got->$_ eq $exp->$_ for qw/requestor channel target direction/;
    }
    $ok ||= !defined $exp && !defined $got;
    ok($ok, "$k parsed ok");
    if (!$ok) {
        diag(Dumper($got,$exp));
    }
}

sub mk_rq {
    return App::Ircxory::Robot::Query::ReasonFor->new({ requestor => $USER,
                                                        channel   => $CHAN,
                                                        target    => $_[0],
                                                        direction => $_[1],
                                                     });
}
