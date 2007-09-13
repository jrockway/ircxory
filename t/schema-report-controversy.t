#!/usr/bin/env perl
# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

use strict;
use warnings;
use Test::More tests => 27;
use App::Ircxory::Test::Database;

my $s = App::Ircxory::Test::Database->connect;

# no controversy
do {
    $s->add_test_record('foo++');
} for (1..15);

# somewhat controversial
do {
    $s->add_test_record('bar++');
    $s->add_test_record('bar--');
    $s->add_test_record('bar++');
} for (1..5);

# no decision
do {
    $s->add_test_record('baz++');
    $s->add_test_record('baz--');
} for (1..10);

do {
    $s->add_test_record('quux++');
    $s->add_test_record('quux--');
} for (1..20);

is($s->karma_for('foo'), 15);
is($s->karma_for('bar'), 5);
is($s->karma_for('baz'), 0);
is($s->karma_for('quux'), 0);

my @c = $s->resultset('Things')->most_controversial->all;
is($c[0]->thing, 'quux', 'quux 1');
is($c[1]->thing, 'baz', 'baz 2');
is($c[2]->thing, 'bar', 'bar 3');
is($c[3]->thing, 'foo', 'foo 4');
ok($c[0]->controversy > $c[1]->controversy, 'make sure there are numbers');
diag join '|', map { $c[$_]->controversy } 0..3;

is($c[0]->ups, 20, 'quux ups');
is($c[0]->downs, 20, 'quux downs');
is($c[1]->ups, 10, 'baz ups');
is($c[1]->downs, 10, 'baz downs');
is($c[2]->ups, 10, 'bar ups');
is($c[2]->downs, 5, 'bar downs');
is($c[3]->ups, 15, 'foo ups');
is($c[3]->downs, 0, 'foo downs');

is($c[0]->total_points, 0, 'total quux');
is($c[1]->total_points, 0, 'total baz');
is($c[2]->total_points, 5, 'total bar');
is($c[3]->total_points, 15, 'total foo');

my @d = $s->resultset('Things')->least_controversial->all;
is($d[0]->thing, 'foo', 'foo 1');
is($d[1]->thing, 'bar', 'bar 2');
is($d[2]->thing, 'quux', 'quux 3');
is($d[3]->thing, 'baz', 'baz 4');
diag join '|', map { $d[$_]->controversy } 0..3;

ok($d[0]->controversy < $d[1]->controversy, 'other way');
ok($d[1]->controversy < $d[2]->controversy, 'other way');
