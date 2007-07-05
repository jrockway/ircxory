#!/usr/bin/env perl
# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

use strict;
use warnings;
use Test::More tests => 21;
use App::Ircxory::Test::Database;

my $s = App::Ircxory::Test::Database->connect;

# no controversy
$s->add_test_record('foo++');
$s->add_test_record('foo++');
$s->add_test_record('foo++');

# somewhat controversial
$s->add_test_record('bar++');
$s->add_test_record('bar--');
$s->add_test_record('bar++');

# no decision
$s->add_test_record('baz++');
$s->add_test_record('baz++');
$s->add_test_record('baz--');
$s->add_test_record('baz--');

is($s->karma_for('foo'), 3);
is($s->karma_for('bar'), 1);
is($s->karma_for('baz'), 0);

my @c = $s->resultset('Things')->most_controversial->all;
is($c[0]->thing, 'baz', 'baz 1');
is($c[1]->thing, 'bar', 'bar 2');
is($c[2]->thing, 'foo', 'foo 3');
ok($c[0]->controversy > $c[1]->controversy, 'make sure there are numbers');
diag join '|', map { $c[$_]->controversy } 0..2;

is($c[0]->ups, 2, 'baz ups');
is($c[0]->downs, 2, 'baz downs');
is($c[1]->ups, 2, 'bar ups');
is($c[1]->downs, 1, 'bar downs');
is($c[2]->ups, 3, 'foo ups');
is($c[2]->downs, 0, 'foo downs');

is($c[0]->total_points, 0, 'total baz');
is($c[1]->total_points, 1, 'total bar');
is($c[2]->total_points, 3, 'total foo');

my @d = $s->resultset('Things')->least_controversial->all;
is($d[0]->thing, 'foo', 'foo 1');
is($d[1]->thing, 'bar', 'bar 2');
is($d[2]->thing, 'baz', 'baz 3');
diag join '|', map { $d[$_]->controversy } 0..2;

ok($d[0]->controversy < $d[1]->controversy, 'other way');
ok($d[1]->controversy < $d[2]->controversy, 'other way');
