#!/usr/bin/env perl
# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

use strict;
use warnings;
use Test::More;
use App::Ircxory::Robot::Parser;
use Readonly;

use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init($FATAL);

Readonly my $ADMIN_USER => 'jrockway!~jrockway@foo.jrock.us';
Readonly my $CHANNEL    => '#foo.bar';
Readonly my $BOT        => 'foobot';

my %COMMANDS = (
    # these 3 actually work
    'foobot: part #foo.bar' => ['part', '#foo.bar'],
    'foobot: join #foo.bar' => ['join', '#foo.bar'],
    'foobot: go away'       => ['shutdown'],
    
    # this fails because the current channel is #foo.bar
    'foobot: part #quux' => [],
    
    # and these three fail because the bot wasn't addressed
    'part #foo.bar' => [],
    'join #foo.bar' => [],
    'go away'       => [],
);

plan tests => scalar keys %COMMANDS;

while (my ($k, $v) = each %COMMANDS) {
    my $got = [(parse($ADMIN_USER, $k, $CHANNEL))];
    my $exp = $v;
    is_deeply($got, $exp, "command '$k' parsed to the right command");
}
