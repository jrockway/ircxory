#!/usr/bin/env perl
# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

use strict;
use warnings;
use Test::More tests => 27;
use App::Ircxory::Robot::Action;
use App::Ircxory::Test::Database;
use App::Ircxory::Robot::Model;

my $schema = App::Ircxory::Test::Database->connect;
$schema->populate(<DATA>);
bless $schema => 'App::Ircxory::Robot::Model';

# do tests
sub kf {
    my ($word,$points) = @_;
    is($schema->karma_for($word),$points, "karma for $word is $points");
}

kf('nothing', 0);
kf('dongs', 3);
kf('perl', 1);
kf('jifty', -1);


sub mf {
    my ($word, $direction, $times) = @_;
    is($schema->karma_for($word, $direction),
       $times, "$word went $direction $times times");
}

# up
mf('nothing', 1, 0);
mf('dongs',   1, 3);
mf('perl',    1, 1);
mf('jifty',   1, 0);

# neutral
mf('nothing', 0, 0);
mf('dongs',   0, 0);
mf('perl',    0, 0);
mf('jifty',   0, 0);

# down
mf('nothing',-1, 0);
mf('dongs',  -1, 0);
mf('perl',   -1, 0);
mf('jifty',  -1, 1);

sub rf {
    my ($word, $expect, $d) = @_;
    is_deeply([sort $schema->reasons_for($word, $d)], [sort @$expect]);
}

rf('nothing', []);
rf('dongs', [qw/splort squirt dongs/]);
rf('jifty', [qw/ajaxy/]);
rf('perl', [qw/perl/]);

rf('perl', [qw/perl/], 1);
rf('perl', [qw/perl/], 0);
rf('perl', [], -1);

rf('foo', [qw/up down/]);
rf('foo', [qw/up/], 1);
rf('foo', [qw/down/], -1);
rf('foo', [qw/up down/], 0);

__END__
Nicknames:
  columns:
    - nid
    - pid
    - nick
    - username
    - host
  data:
    - 
      - 1
      - 1
      - jrockway
      - jon
      - jrock.us
    -
      - 2
      - 1
      - jrockway
      - jon
      - foo.jrock.us
    -
      - 3
      - 2
      - avar
      - avar
      - iceland/or/something

People:
  columns:
    - pid
    - name
  data:
    -
     - 1
     - jrockway
    - 
     - 2
     - avar

Things:
  columns:
    - tid
    - thing
  data:
    -
     - 1
     - perl
    -
     - 2
     - jifty
    - 
     - 3
     - dongs
    -
     - 4
     - foo

Opinions:
  columns:
    - oid
    - nid
    - tid
    - cid
    - points
    - reason
    - message

  data:
    -
     - 1
     - 1
     - 1
     - 1
     - 1
     - perl
     - "perl++ # perl"
    -
     - 2
     - 1
     - 2
     - 1
     - "-1"
     - ajaxy
     - "jifty-- # ajaxy"
    - 
     - 3
     - 3
     - 3
     - 1
     - 1
     - splort
     - "dongs++ # splort"
    - 
     - 4
     - 3
     - 3
     - 1
     - 1
     - squirt
     - "dongs++ # squirt"
    -
     - 5
     - 2
     - 3
     - 1
     - 1
     - dongs
     - "dongs++ # dongs"
    -
     - 6
     - 2
     - 4
     - 1
     - 1
     - up
     - "foo++ # up"
    -
     - 7
     - 2
     - 4
     - 1
     - "-1"
     - down
     - "foo-- # down"


Channels:
  columns:
    - cid
    - channel
  data:
    -
     - 1
     - #perl
