#!/usr/bin/env perl
# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

use strict;
use warnings;
use Test::More;
use App::Ircxory::Robot::Action;
use App::Ircxory::Robot::Parser;
use Readonly;
use App::Ircxory::Robot::Query::KarmaFor;
use Data::Dumper;

use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init($FATAL);

Readonly my $USER       => 'me!~me@my/machine';
Readonly my $CHAN       => '#foo.bar';
Readonly my $BOT        => 'foobot';
my $BOTINFO = { nick => $BOT};

my %COMMANDS = (
                'foobot: karma for jrockway'  => mk_kq('jrockway'),
                'foobot: karma jrockway'      => mk_kq('jrockway'),
                'foobot: karma for jrockway?' => mk_kq('jrockway'),
                'foobot: karma jrockway?'     => mk_kq('jrockway'),
                'hello there foobot'          => undef,
                'foobot: sungo it!'           => undef,
                'la la la'                    => undef,
               );

plan tests => (scalar keys %COMMANDS);


while (my ($k, $v) = each %COMMANDS) {
    no warnings 'uninitialized';
    my $got = parse($BOTINFO, $USER, $k, $CHAN);
    my $exp = $v;

    my $ok = 0;
    if (defined $exp && defined $got) {
        $ok = 1;
        $ok &&= $got->$_ eq $exp->$_ for qw/requestor channel target/;
    }
    $ok ||= !defined $exp && !defined $got;
    ok($ok, "$k parsed ok");
    if (!$ok) {
        diag(Dumper($got,$exp));
    }
}

sub mk_kq {
    return App::Ircxory::Robot::Query::KarmaFor->new({ requestor => $USER,
                                                       channel   => $CHAN,
                                                       target    => $_[0],
                                                     });
}
