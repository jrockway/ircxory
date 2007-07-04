#!/usr/bin/env perl
# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

use strict;
use warnings;
use Test::More tests => 11;
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
is($c[0]->thing, 'baz');
is($c[1]->thing, 'bar');
is($c[2]->thing, 'foo');
ok($c[0]->controversy < $c[1]->controversy, 'make sure there are numbers');

my @d = $s->resultset('Things')->least_controversial->all;
is($d[0]->thing, 'foo');
is($d[1]->thing, 'bar');
is($d[2]->thing, 'baz');
ok($d[0]->controversy > $d[1]->controversy, 'other way');
