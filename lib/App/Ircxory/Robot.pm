# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

package App::Ircxory::Robot;
use strict;
use warnings;

use Carp;
use Log::Log4perl;
use POE qw(Component::IRC);
use POE::Kernel;
use App::Ircxory::Robot::Action;
use App::Ircxory::Robot::Parser;
use Data::Dumper;

=head1 NAME

App::Ircxory::Robot - the ircbot to collect ratings

=head1 SYNOPSIS

    my $bot = App::Ircxory::Robot->
        new({ nick     => 'spybot',
              server   => 'irc.perl.org',
              channels => [qw|#chicago.pm #dongs #catalyst|],
              model    => App::Ircxory::Robot::Model->connect, 
            });
 
    $bot->go; # blocks

    sub callme {
        my $action = shift; # App::Ircxory::Robot::Action object
        my $who    = $action->nick;
        my $what   = $action->word;
        print "Wow, did you know that $who likes $what?" 
          if $action->points > 0
    }

=head1 DESCRIPTION

It's an IRC bot.  It sits and listens to the channels, looking for
people plusplus and minusminus-ing things.  When that happens, the
event is inserted into the database via App::Ircxory::Schema.

=head1 METHODS

=head2 new({server => 'irc.perl.org', ...});

Create a new IRC bot.  Required args are C<nick>, C<server>,
C<channels> (and arrayref), and C<callback>.  C<callback> is a coderef
that is called with a App::Ircxory::Robot::Action when the bot detects
some relevant activity.

=head2 go

Start the bot.  Returns when the bot is asked to quit.

=head1 INTERNAL METHODS

These are for POE.

=head2 irc_001

Init connection.

=head2 irc_public

Recieve a public message (in a channel), parse it, and call the
callback if necessary.

=head2 _default

Nothing really.

=head2 _start

Start the IRC bot.

=cut

sub new {
    my $class = shift;
    my $self  = shift;
    
    # read args
    croak 'need nick'     unless $self->{nick};
    croak 'need server'   unless $self->{server};
    croak 'need channels' unless ref $self->{channels} eq 'ARRAY';
    croak 'need model'    unless ref $self->{model};
    
    # init bot
    my $irc = POE::Component::IRC->
      spawn( 
            nick    => $self->{nick},
            server  => $self->{server},
            port    => $self->{port} || 6667,
            ircname => __PACKAGE__,
           ) or croak "Failed to create IRC Bot: $!";

    # init session (based on this object)
    $self = bless $self => $class;
    my $session = POE::Session->
      create(
             object_states => [$self => 
                               { '_default'   => '_default',
                                 '_start'     => '_start',
                                 'irc_001'    => 'irc_001',
                                 'irc_public' => 'irc_public',
                               },
                              ],
             heap => { irc => $irc, instance => $self },
            );
    
    $self->{session} = $session;
    return $self;
}

sub go {
    my $self = shift;
    POE::Kernel->run();
}

sub _start {
    my ($kernel,$heap) = @_[KERNEL,HEAP];
    my $irc_session = $heap->{irc}->session_id();
    
    $kernel->post( $irc_session => register => 'all' );
    $kernel->post( $irc_session => connect => { } );
    
    return;
}

sub irc_001 {
    my ($kernel,$sender,$heap) = @_[KERNEL,SENDER,HEAP];
    my $poco_object = $sender->get_heap();
    my $log = Log::Log4perl->get_logger(__PACKAGE__);
    
    $log->info("Connected to ", $poco_object->server_name());
    
    my @channels = @{$heap->{instance}->{channels}||[]};
    for (@channels){
        $log->info("Joining $_");
        $kernel->post( $sender => join => $_ );
    }
    
    return;
}

sub irc_public {
    my ($kernel,$sender,$heap,$who,$where,$what) = 
      @_[KERNEL,SENDER,HEAP,ARG0,ARG1,ARG2];

    my $log = Log::Log4perl->get_logger('App::Ircxory::Robot');

    # parse the event
    my @result = parse($heap->{irc}, $who, $what, $where);
    my $first = $result[0];
    return unless defined $first;
    
    my $cmd = ref $first;
    if (!$cmd) {
        # not a ref, post a POE event
        $kernel->post($sender => @result);
        return;
    }
    
    # a ref, consult a lookup table
    my %EVENT_DISPATCH =
      ( 'App::Ircxory::Robot::Action' => 
        sub {     
            $log->debug('logging an opinion: '. Dumper($first));
            $heap->{instance}{model}->record($first);
        },
        
        'App::Ircxory::Robot::Query::KarmaFor' =>
        sub {
            my ($nick) = parse_nickname($who);
            my $target = $first->target;
            $log->debug("karma request for $target by $who");
            my $karma = $heap->{instance}{model}->karma_for($target);
            $karma = ($karma) ? "karma of $karma" : "neutral karma";
            $kernel->post($sender => 'privmsg' => $where =>
                          "$nick: $target has $karma");
        },  
        
        'App::Ircxory::Robot::Query::ReasonFor' =>
        sub {
            my ($nick)    = parse_nickname($who);
            my $target    = $first->target;
            my $direction = $first->direction;
            $log->debug("reason request for $target by $who");
            my @reasons = $heap->{instance}{model}->
              reasons_for($target, $direction);

            my $rd  = ($direction > 0 ? 'like' : 'dislike');
            
            map {$_ = qq{"$_"}} @reasons;
            my $foo = pop @reasons;
            my $bar = pop @reasons;
            my $baz = pop @reasons;
            
            my $msg = "$nick: people $rd $target because of ";
            my $front = join ', ', @reasons;
            if ($front && $baz) {
                $msg .= "$front, $baz, $bar, and $foo";
            }
            elsif ($bar) {
                $msg .= "$bar, $bar, and $foo";
            }
            elsif ($bar) {
                $msg .= "$bar and $foo";
            }
            elsif ($foo) {
                $msg .= "$foo... why else?";
            }
            else {
                $msg = "there's really no reason to $rd $target, $nick";
            }
            
            $kernel->post($sender => 'privmsg' => $where => $msg);
        },
      );
    
    eval { no warnings; $EVENT_DISPATCH{$cmd}->() };
    if ($@) {
        $log->warn("unknown command $cmd ($@)");
    }
    return;
}

sub _default {
    my ($event, $args) = @_[ARG0 .. $#_];
    #my @output = ( "$event: " );
    # 
    #foreach my $arg ( @$args ) {
    #    if ( ref($arg) eq 'ARRAY' ) {
    #        push( @output, "[" . join(" ,", @$arg ) . "]" );
    #    } else {
    #        push ( @output, "'$arg'" );
    #    }
    #}
    #print STDOUT join ' ', @output, "\n";
    return 0;
}

1;
