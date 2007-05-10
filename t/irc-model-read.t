#!/usr/bin/env perl
# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

use strict;
use warnings;
use Test::More tests => 9;
use YAML;
use Directory::Scratch;
use App::Ircxory::Schema;
use App::Ircxory::Robot::Model;
use App::Ircxory::Robot::Action;

# setup database
my $tmp = Directory::Scratch->new;
my $db  = $tmp->touch('database');

my $schema = App::Ircxory::Schema->connect("DBI:SQLite:$db");
$schema->deploy;
bless $schema => 'App::Ircxory::Robot::Model'; # ick.
isa_ok($schema, 'App::Ircxory::Robot::Model');

# read test fixtures from __END__
my $data = do { local $/; <DATA> };
$data = YAML::Load($data);

# INSERT fixtures INTO database
foreach my $table (keys %$data) {
    my $rs   = $schema->resultset($table);
    my @cols = @{$data->{$table}{columns}};
    
    foreach my $row (@{$data->{$table}{data}}) {
        my $i = 0;
        my $r = {};
        foreach my $col (@cols) {
            $r->{$col} = $row->[$i++];
        }
        $rs->create($r);
    }
}

# do tests
sub kf {
    my ($word,$points) = @_;
    is($schema->karma_for($word),$points, "karma for $word is $points");
}

kf('nothing', 0);
kf('dongs', 3);
kf('perl', 1);
kf('jifty', -1);

sub rf {
    my ($word, $expect) = @_;
    is_deeply([sort $schema->reasons_for($word)], [sort @$expect]);
}

rf('nothing', []);
rf('dongs', [qw/splort squirt dongs/]);
rf('jifty', [qw/ajaxy/]);
rf('perl', [q/perl/]);

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

Channels:
  columns:
    - cid
    - channel
  data:
    -
     - 1
     - #perl
