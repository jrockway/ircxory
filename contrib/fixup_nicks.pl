#!/usr/bin/env perl
# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

use strict;
use warnings;

use App::Ircxory::Schema;

my $schema = App::Ircxory::Schema->connect(@ARGV, { AutoCommit => 0 });
my @nicks = $schema->resultset('Nicknames')->all;
$schema->txn_do(
  sub {
    nick:
      foreach my $nick (@nicks) {
          my $name = $nick->person->name;
          my $orig_person = $nick->person;
          if($name =~ /^(?:[^A-Za-z])?([A-Za-z]+)(?:[^A-Za-z])?$/ 
             && $name ne $1)
            {
                my $real = $1;
                print "$name looks like $real\n";
                
                my $person = $schema->resultset('People')->
                  search({ name => $real })->first;
                if($person){
                    print "    * Change $name -> ". $person->name. "\n";
                    $nick->update({ pid => $person->pid });
                    if($orig_person->nicknames->count < 1){
                        print "        * Delete person $name\n";
                        $orig_person->delete;
                    }
                }
            }
      }
      print {*STDERR} "Type y to COMMIT or n to ROLLBACK\n";
      my $yes = <STDIN>;
      chomp $yes;
      if($yes ne 'y'){ die "ROLLBACK" }
      print {*STDERR} "COMMIT\n";
  });
