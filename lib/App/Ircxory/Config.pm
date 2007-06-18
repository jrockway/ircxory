# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

package App::Ircxory::Config;
use strict;
use warnings;
use FindBin qw($Bin);
use YAML; # not CaML

=head1 NAME

App::Ircxory::Config - manage configuration information for App::Ircxory

=head1 SYNOPSIS

   my $config = App::Ircxory::Config->load;

=head1 METHODS

=head2 load

Load the config hash into memory

=cut

sub load {
    my $class = shift; # don't care
    my $file  = "$Bin/../app_ircxory.yml";

    return YAML::LoadFile($file);
}

1;
