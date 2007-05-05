#!/usr/bin/env perl
# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

use strict;
use warnings;
use Test::More tests => 1;
use App::Ircxory::Config;

my $config = App::Ircxory::Config->load;
is(ref $config, 'HASH', 'got a hashref of config');
