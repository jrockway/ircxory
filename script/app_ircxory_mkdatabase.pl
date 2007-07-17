#!/usr/bin/env perl
# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/../lib";
use App::Ircxory::Robot::Model;
use App::Ircxory::Schema;

my $schema = App::Ircxory::Robot::Model->connect or die "Failed to connect";
$schema->deploy;

# person
my $person  = rs('People')->    create({ name     => 'jrockway' });

# person has_many nicks
my $nick    = rs('Nicknames')-> create({ person   => $person,
                                         nick     => 'jrockway',
                                         username => 'jrockway',
                                         host     => 'dsl-12-34-56-78.blah',
                                       });

# thing
my $thing   = rs('Things')->    create({ thing    => 'perl' });

# channel
my $channel = rs('Channels')->  create({ channel  => '#perl'});

# opinions match nicks to opinions on things
my $opinion = rs('Opinions')->  create({ nickname => $nick,
                                         thing    => $thing,
                                         message  => 'perl++ # perl rules',
                                         reason   => 'perl rules',
                                         points   => 1,
                                         channel  => $channel,
                                       });

print "Created first opinion with id ". $opinion->id. "\n";

sub rs {
    return $schema->resultset($_[0]);
}
