#!/usr/bin/env perl
# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

use strict;
use warnings;
use Test::More;
use App::Ircxory::Robot::Action;
use App::Ircxory::Robot::Parser;
use Readonly;
use Data::Dumper;

use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init($FATAL);

Readonly my $ADMIN_USER => 'jrockway!~jrockway@foo.jrock.us';
Readonly my $USER       => 'me!~me@my/machine';
Readonly my $CHANNEL    => '#foo.bar';
Readonly my $BOT        => 'foobot';

my %COMMANDS = (
                # these 3 actually work
                'foobot: part #foo.bar' => ['part', '#foo.bar'],
                'foobot: join #foo.bar' => ['join', '#foo.bar'],
                'foobot: go away'       => ['shutdown'],
                
                # this fails because the current channel is #foo.bar
                'foobot: part #quux' => [],
                
                # and these three fail because the bot wasn't addressed
                'part #foo.bar' => [],
                'join #foo.bar' => [],
                'go away'       => [],
               );

my %OPINIONS = (
                # start with the basics
                'foo++ # bar' => mk_action('foo', 'bar',  1),
                'foo++'       => mk_action('foo', undef,  1),
                'foo-- # bar' => mk_action('foo', 'bar', -1),
                'foo--'       => mk_action('foo', undef, -1),
                
                # grouping
                '(foo)++'     => mk_action('foo', undef,  1),
                '[foo]++'     => mk_action('foo', undef,  1),
                '{foo}++'     => mk_action('foo', undef,  1),
                
                # spaces
                '  foo++  '   => mk_action('foo', undef,  1),
                '( foo )++'   => mk_action('foo', undef,  1),
                '[ foo ]++'   => mk_action('foo', undef,  1),
                '{ foo }++'   => mk_action('foo', undef,  1),

                # capitals
                'FOO++'       => mk_action('foo', undef,  1),
                
                # things with spaces
                '(something I like a whole darn lot)++ # i like it'
                => mk_action('something i like a whole darn lot', 
                             'i like it', 1),
                
                # Perl::Modules
                'Acme::Read::Like::A::Monger++' 
                => mk_action('acme::read::like::a::monger', undef, 1),

                # weird stuff
                '++++' => undef,
                '----' => undef,
                '+-+-' => undef,
                'this is totally irrelevant' => undef,
               );
                
# the +1 is for testing channel name escaping in regexes (bug #1, heh)
plan tests => (scalar keys %COMMANDS) + (scalar keys %OPINIONS) + 1;

{
    my $got = [(parse($ADMIN_USER, 'foobot: part #perl++', '#perl++'))];
    is_deeply($got, ['part', '#perl++'], 'part #perl++ works');
}

while (my ($k, $v) = each %COMMANDS) {
    my $got = [(parse($ADMIN_USER, $k, $CHANNEL))];
    my $exp = $v;
    is_deeply($got, $exp, "command '$k' parsed to the right command");
}

while (my ($k, $v) = each %OPINIONS) {
    my $got = parse($USER, $k, $CHANNEL);
    my $exp = $v;
    
    is_same($got, $exp, "$k parsed to the correct action");
}

sub is_same {
    no warnings 'uninitialized';
    my $got      = shift;
    my $expected = shift;
    my $message  = shift;

    # undef == undef
    if (!defined $got && !defined $expected) {
        pass($message);
        return;
    }

    # something undef? not good.
    unless (defined $got && defined $expected){
        fail($message);
        diag("dump: ". Dumper(defined $got ? $got : $expected));
        return;
    }
    
    # compare two hashes
    my %g = %$got;
    my %x = %$expected;

    delete $g{message}; # we don't care about this really
    delete $x{message}; 
    
    foreach (keys %g, keys %x) { # make sure one hash doesn't have an extra key
        if ($g{$_} ne $x{$_}){
            fail($message);
            diag("Compare failed on key '$_'");
            diag("      got: ". $g{$_});
            diag(" expected: ". $x{$_});
            return;
        }
        $got->      $_; # make sure accessors work too
        $expected-> $_; 
    }
    
    # didn't fail in there? pass.
    pass($message);
    return;
}

sub mk_action {
    my $word   = shift;
    my $reason = shift;
    my $points = shift;

    return App::Ircxory::Robot::Action->
      new({ who     => $USER,
            channel => $CHANNEL,
            word    => $word,
            reason  => $reason,
            points  => $points,
          });
}
