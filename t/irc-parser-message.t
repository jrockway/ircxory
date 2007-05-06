#!/usr/bin/env perl
# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

use strict;
use warnings;
use Test::More;
use App::Ircxory::Robot::Action;
use App::Ircxory::Robot::Parser;
use Data::Dumper;
use Readonly;

Readonly my $USER    => 'jrockway!~jon@jrock.us';
Readonly my $CHANNEL => '#perl++';

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
                
plan tests => scalar keys %OPINIONS;

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
