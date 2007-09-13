#!/usr/bin/env perl
# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

use strict;
use warnings;
use Test::More tests => 2;

use App::Ircxory::Test::Database;
my $s = App::Ircxory::Test::Database->connect;

$s->add_test_record(@$_) for 
  # what                       author
  (['foo++',                   'jrockway!~jrockway@foo.jrock.us'],
   ['bar++',                   'jrockway!~jrockway@bar.jrock.us'],
   ['test++',                  'test!~test@test'                ],
   ['ignore-- # has a reason', 'ignore!~ignore@ignore'          ],
   ['both--',                  'both!~both@both'                ],
   ['both-- # has a reason',   'both!~both@both'                ],
  );

my ($ups, $downs) = $s->resultset('Things')->no_comment;
is_deeply [sort @$ups], [sort qw/jrockway test/], 'got ups';
is_deeply [sort @$downs], [sort qw/both/], 'got downs';
