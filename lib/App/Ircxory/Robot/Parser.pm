# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

package App::Ircxory::Robot::Parser;
use strict;
use warnings;

use base 'Exporter';
our @EXPORT = qw(parse parse_nickname);

use Log::Log4perl;

=head1 NAME

App::Ircxory::Robot::Parser - parse IRC messages into events

=head1 EXPORT

=head2 parse

Parses a message and returns an object or a list.  A list is just passed
thru to post.

=cut

sub parse {
    my $who   = shift;
    my $what  = shift;
    my $where = shift;
    my $when  = shift;
    my $why   = shift;
    my $how   = shift; # ok, some of these are made up

    my $log   = Log::Log4perl->get_logger('App::Ircxory::Robot');

    $where = @{$where}[0] if ref $where eq 'ARRAY';

    my ($nick, $login, $host) = parse_nickname($who);

    # respond to an admin command
    if ($nick eq 'jrockway') { # yay
        if ($what =~ /^\w+: part $where$/) {
            $log->debug("$who asked us to part $where");
            return ('part', $where);
        }
        
        if ($what =~ /^\w+: join (#.+)$/) {
            $log->debug("$who asked us to part $1");
            return ('join', $1);
        }

        if ($what =~ /^\w+: go away$/){
            $log->debug("$who asked us to shutdown (on $where)");
            return ('shutdown');
        }
    }

    return;
}

=head2 parse_nickname

Given a nick + hostmask, returns an array of nick, login, hostmask.

=cut

sub parse_nickname {
    my $in = shift;
    my ($nick, $hoststuff) = split /!~?/, $in;
    my ($user, $host) = split /@/, $hoststuff;

    return ($nick, $user, $host);
}

1;
