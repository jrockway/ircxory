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

my $last  = 1;
my $order = 'DESC';
while (defined (my $algo = $term->readline('> '))) {
    # exit
    exit if $algo =~ /^q(u(i(t)?)?)?$/;
    
    # special commands
    if ($algo =~ /(?:;|ASC|DESC)/) {
        $order = 'ASC'  if $algo eq 'ASC';
        $order = 'DESC' if $algo eq 'DESC';
        $order = ($order eq 'DESC' ? 'ASC' : 'DESC') if ($algo eq ';');
        $algo  = $last;
    }
    
    my $rs = $schema->resultset('Things')->_controversial(20, $algo, $order);
    print "(sorted $order)\n";
    while (my $row = $rs->next) {
        my $thing = $row->thing;
        $thing .= " " x 30;
        print substr($thing,0,15). " ";
        print join "\t", map {substr($row->get_column($_)." " x 5,0,5)} 
          qw/total_points c controversy/;
        print "\n";
    }
    $last = $algo;
}
