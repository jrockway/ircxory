# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

package App::Ircxory::Robot::Parser;
use strict;
use warnings;

use base 'Exporter';
our @EXPORT = qw(parse parse_nickname);

use Regexp::Common qw/balanced/;
use Log::Log4perl;
use Readonly;
Readonly my %OP_POINTS => ( '++' => 1,
                            '--' => -1,
                            '-+' => 0,
                            '+-' => 0,
                          );

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
        my $chan = quotemeta $where;
        if ($what =~ /^\w+: part $chan$/) {
            $log->debug("$who asked us to part $chan");
            return ('part', $where);
        }
        
        if ($what =~ /^\w+: join (#.+)$/) {
            $log->debug("$who asked us to join $1");
            return ('join', $1);
        }

        if ($what =~ /^\w+: go away$/){
            $log->debug("$who asked us to shutdown (on $where)");
            return ('shutdown');
        }
    }

    my $parens =  $RE{balanced}{-parens=>'(){}[]<>'}{-keep};
    if ($what =~ /(?: # what we're voting on
                      $parens        # something in parens
                      |
                      ([A-Za-z_:0-9]+)  # a single word++
                  )
                  ([+-]{2})          # the operation (inc or dec)
                  \s*                # spaces, who cares
                  (?:[#] \s* (.+)$)?  # and an optional reason
                 /x
       )
      {
          my $paren  = $1;
          my $word   = $2;
          if (defined $paren) {
              $paren =~ s/^[({[<]//;
              $paren =~ s/[)}\]>]$//;
              $word = $paren;
          }

          my $op     = $3;
          my $reason = $4;
          $reason = '' if !defined $reason; # fix in perl5.10 //

          # trim
          $word   =~ s/^\s+//;
          $word   =~ s/\s+$//;
          $reason =~ s/^\s+//;
          $reason =~ s/\s+$//;
          
          # and finally return
          return App::Ircxory::Robot::Action->
            new({
                 who     => $who,
                 word    => lc $word,
                 reason  => lc $reason,
                 points  => $OP_POINTS{$op} || 0,
                 channel => $where,
                 message => $what,
                });
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
