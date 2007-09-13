#!/usr/bin/env perl
# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

use strict;
use warnings;
use Test::More tests => 7;
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

is_deeply [map { $s->karma_for($_) } qw/foo bar baz quux/],
  [15, 5, 0, 0], 'karma for each thing we just added';

my @c = $s->resultset('Things')->most_controversial->all;
is_deeply [map { $_->thing } @c], [qw/quux baz bar foo/],
  'most controversial returns item in correct order';

ok($c[0]->controversy > $c[1]->controversy, 'sort order is correct');
diag join '|', map { $c[$_]->controversy } 0..3;

is_deeply [map { $_->ups, $_->downs } @c],
  [20 => 20, 10 => 10, 10 => 5, 15 => 0],
  'ups and downs are what we expected; in the right order';

is_deeply [map { $_->total_points } @c], [0, 0, 5, 15],
  'total points are in ascending (abs) order';

my @d = $s->resultset('Things')->least_controversial->all;
is_deeply [map { $_->thing } @d], [qw/foo bar quux baz/],
  'least_controversial orders things correctly';

diag join '|', map { $d[$_]->controversy } 0..3;
ok($d[0]->controversy < $d[1]->controversy, 'sorts the other way');
