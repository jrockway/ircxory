#!/usr/bin/env perl
# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

use strict;
use warnings;
use Test::More tests => 1;
use App::Ircxory::Test::Database;
use App::Ircxory::Robot::Action;

my @RECORDS = ([qw/test  1/],
               [qw/test -1/],
               [qw/foo   1/],
               [qw/foo   1/],
               [qw/bar  -1/],
               [qw/baz   0/],
              );

my @EXPECT  = ([qw/foo   2/],
               [qw/baz   0/],
               [qw/test  0/],
               [qw/bar  -1/],
              );

my $schema  = App::Ircxory::Test::Database->connect;
$schema->record(App::Ircxory::Robot::Action->
                new({ who     => 'foo!~foo@test.com',
                      word    => $_->[0],
                      points  => $_->[1],
                      channel => '#test',
                      reason  => 'test',
                      message => 'test',
                    }))
  for @RECORDS;


my @everything = $schema->everything;
is_deeply(\@everything, \@EXPECT, 'got expected everything');
