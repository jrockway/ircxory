#!/usr/bin/env perl
# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use App::Ircxory::Robot::Model;
use Term::ReadLine;

my $term   = Term::ReadLine->new($0);
my $schema = App::Ircxory::Robot::Model->connect;

while (defined (my $algo = $term->readline('> '))) {
    exit if $algo =~ /^[.]q(u(i(t)?)?)?$/;
    my $rs = $schema->resultset('Things')->_controversial(20, $algo, 'DESC');
    while (my $row = $rs->next) {
        my $thing = $row->thing;
        $thing .= " " x 30;
        print substr($thing,0,30);
        print join "\t", map {substr($row->get_column($_)." " x 5,0,5)} 
          qw/total_points c controversy/;
        print "\n";
    }
}
