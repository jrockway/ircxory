#!/usr/bin/env perl
# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

use strict;
use warnings;
use Test::More tests => 6;
use App::Ircxory::Test::Database;
use Test::Exception;

# some test data
my @GOOD_THINGS = qw(foo bar baz quux foobarbaz foobar
                     catalyst perl dbic irc ircxory jrockway);
my @BAD_THINGS  = qw(food bars bazzed foodbarsbazzed foodbars
                     jifty ruby activerecord msn doxory dhh);


# CONNECT TO the database USING a temporary file
my $schema = App::Ircxory::Test::Database->connect;
_record_actions(1, @GOOD_THINGS);
_record_actions(-1, @BAD_THINGS);

my @TOP_TEN    = (reverse @GOOD_THINGS)[0..9];
my @BOTTOM_TEN = (reverse @BAD_THINGS )[0..9];

# make sure we die when given bad input
throws_ok { $schema->highest(10, -2) }
  qr/bad multiplier/,
  '-2 is not a valid multiplier';

lives_ok { $schema->highest(10, -1) }
  'bottom 10 is legal';


my @topten = $schema->highest();
is_deeply(\@topten, \@TOP_TEN, 'got top ten');

my @botten = $schema->highest(10, -1);
is_deeply(\@botten, \@BOTTOM_TEN, 'got bottom ten');

my @topnine = $schema->highest(9);
is_deeply(\@topnine, [@TOP_TEN[0..8]], 'got top nine');

my @botfour = $schema->highest(4, -1);
is_deeply(\@botfour, [@BOTTOM_TEN[0..3]], 'got bottom four');

# add elements in an array with $points.  the first
# element is added once, the second twice, etc.
sub _record_actions {
    my $points = shift || die "need points";
    my $char   = $points > 0 ? "++" : "--";
    my @things = @_;
    my $i = 1;
    foreach my $thing (@things) {
        my $j = $i;
        while ($j-- > 0) {
            my $action = App::Ircxory::Robot::Action->
              new({ who       => 'jrockway!~jon@jrock.us',
                    message   => qq{$thing$char # $i.$j $points},
                    word      => $thing,
                    points    => $points,
                    reason    => qq{$i.$j $points},
                    channel   => '#plusplus',
                  });
            $schema->record($action);
        }
        $i++;
    }
}
