#!/usr/bin/env perl
# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

use strict;
use warnings;
use Test::More tests => 12;
use Directory::Scratch;
use App::Ircxory::Schema;
use App::Ircxory::Robot::Model;
use App::Ircxory::Robot::Action;

my $tmp = Directory::Scratch->new;
my $db  = $tmp->touch('database');

my $schema = App::Ircxory::Schema->connect("DBI:SQLite:$db");
$schema->deploy;
bless $schema => 'App::Ircxory::Robot::Model'; # ick.

isa_ok($schema, 'App::Ircxory::Robot::Model');

my $person;
{
    my $nick = $schema->_get_nickname('jrockway', 'jon', 'jrock.us');
    is($nick->nick, 'jrockway');
    ok($nick->person, 'have a person');
    is($nick->person->name, 'jrockway', 'created a person with nick as name');
    
    my $old_person = $nick->person;
    $nick = $schema->_get_nickname('jrockway', 'jon', 'foo.jrock.us');
    is($nick->nick, 'jrockway');
    ok($nick->person, 'have a person');
    is($nick->person->name, 'jrockway', 'created a person with nick as name');
    is($nick->person->pid, $old_person->pid, 'same person as before');

    $person = $nick->person; # for comparison later
}

my $action = App::Ircxory::Robot::Action->
  new({ who       => 'jrockway!~jon@jrock.us',
        message   => q{plusplus++ # it's fun},
        word      => 'plusplus',
        points    => 1,
        reason    => q{it's fun},
        channel   => '#plusplus',
      });

my $opinion = $schema->record($action);

ok($opinion, 'inserted opinion record ok');
is($opinion->nickname->person->pid, $person->pid, "opinion person is the same");
is($opinion->channel->channel, '#plusplus');
is($opinion->thing->thing, 'plusplus');
