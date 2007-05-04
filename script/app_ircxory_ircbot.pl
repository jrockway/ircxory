#!/usr/bin/env perl
# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

use strict;
use warnings;

use YAML;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use App::Ircxory::Robot;
use Log::Log4perl;

# setup log4perl
my $logconfig  = "$Bin/../root/ircbotlog.conf";
Log::Log4perl->init($logconfig);
my $log = Log::Log4perl->get_logger('App::Ircxory::Robot');

# load app config file
my $configfile = "$Bin/../app_ircxory_config.yml";
$log->debug("Loading config file $configfile");
my $config;
eval {
    $config = YAML::LoadFile($configfile);
};
if ($@) {
    $log->error("Error loading config file: $@");
    die;
}

die "The config file $configfile needs a 'bot' section" 
  unless ref $config->{bot};

# load the bot
$log->debug("Loading bot");
my $bot;
eval {
    $bot = App::Ircxory::Robot->new({%{$config->{bot}}, callback => sub{}});
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
