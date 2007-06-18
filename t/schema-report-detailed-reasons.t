#!/usr/bin/env perl
# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

use strict;
use warnings;
use Test::More tests => 1;
use App::Ircxory::Test::Database;

my @REASONS = ( [ 'test', 'jrockway', 1 ],
                [ 'foo',  'someone',  0 ],
                [ 'boo',  'buu',     -1 ],
              );

# CONNECT TO the database USING a temporary file
my $schema = App::Ircxory::Test::Database->connect;
_record_reasons('testing', @REASONS);

my @res = map { [$_->reason, $_->person, $_->points] }
  $schema->resultset('Things')->reasons_for('testing');

is_deeply([sort {$a->[0] cmp $b->[0]} @res],
          [sort {$a->[0] cmp $b->[0]} @REASONS],
          'got same reasons as inserted');

sub _record_reasons {
    my $thing   = shift;
    my @reasons = @_;
    foreach (@reasons) {
        my ($reason, $person, $points) = @{$_};
        my $action = App::Ircxory::Robot::Action->
          new({ who      =>"$person!~$person\@$person",
                message  =>qq{$thing # $reason},
                word     =>$thing,
                points   =>$points,
                reason   =>$reason,
                channel  =>'#plusplus',
              });
        $schema->record($action);
    }
}

