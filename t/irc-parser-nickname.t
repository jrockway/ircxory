#!/usr/bin/env perl
# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

use strict;
use warnings;
use Test::More;
use App::Ircxory::Robot::Parser;

my %data = 
  ( 
   # me @ foo
   'jrockway!~jrockway@dsl092-134-178.chi1.dsl.speakeasy.net' =>
    [ 'jrockway', 'jrockway', 'dsl092-134-178.chi1.dsl.speakeasy.net']

  );

plan tests => scalar keys %data;

while (my ($k, $v) = each %data) {
    my $get    = [parse_nickname($k)];
    my $expect = $v;
    is_deeply($get, $expect, "$k parses");
}
