#!/usr/bin/env perl
# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

use strict;
use warnings;
use Test::More tests => 6;
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
