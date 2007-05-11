#!/usr/bin/env perl
# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

use strict;
use warnings;

use YAML;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use App::Ircxory::Robot;
use App::Ircxory::Robot::Action;
use App::Ircxory::Robot::Model;
use App::Ircxory::Config;
use Log::Log4perl;

my @channels = @ARGV;

# setup log4perl
my $logconfig  = "$Bin/../root/ircbotlog.conf";
Log::Log4perl->init($logconfig);
my $log = Log::Log4perl->get_logger('App::Ircxory::Robot');

# load app config file
$log->debug("Loading config file");
my $config;
eval {
    $config = App::Ircxory::Config->load;
};
if ($@) {
    $log->error("Error loading config file: $@");
    die;
}

die "The config file needs a 'bot' section" 
  unless ref $config->{bot};

$config->{bot}->{channels} = [@channels] if @channels;

# connect to the database
$log->debug("Connecting to the database");
my $recorder = App::Ircxory::Robot::Model->connect;

# load the bot
$log->debug("Loading bot");
my $bot;
eval {
    $bot = App::Ircxory::Robot->new({
                                     %{$config->{bot}}, 
                                     callback => $recorder->get_recorder
                                    });
};
if ($@) {
    $log->error("Error creating ircbot: $@");
    die;
}

# connect to server and join channels, enter main event loop
$log->debug("Connecting to ". $bot->{server});
$bot->go;

# we're done, exit
$log->debug("Bot exiting");
exit 0;
