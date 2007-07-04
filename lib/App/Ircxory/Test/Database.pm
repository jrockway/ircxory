# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

package App::Ircxory::Test::Database;
use strict;
use warnings;
use Directory::Scratch;
use YAML;
use App::Ircxory::Robot::Parser;
use Regexp::Common qw/balanced/;

use base 'App::Ircxory::Schema';

=head1 NAME

App::Ircxory::Test::Database - create and populate a test database

=head1 SYNOPSIS

   my $schema = App::Ircxory::Test::Database->connect;
   $schema->populate; # load YAML data from <DATA>

   $schema->resultset(...); # and now you can test!

=head1 METHODS

=head2 new

Connect to the database and deploy the schema.  Returns the schema.

=cut

sub connect {
    my $class = shift;
    # setup database
    my $tmp = Directory::Scratch->new;
    my $db  = $tmp->touch('database');
    
    my $schema = $class->SUPER::connect("DBI:SQLite:$db");
    $schema->deploy;
    return $schema;
}

=head2 populate(@_)

Read @_ as lines of YAML and insert that data into the database.

Format is:

    Table1:
      columns:
         - id
         - col2
         - ...
      data:
         -
           - <id1>
           - <col2,1>
           - ...
         -
           - <id2>
           - ....
    Table2:
      ...
    ...
    
=cut

sub populate {
    my $schema = shift;
    my $data   = YAML::Load(join '', @_);
    
    # INSERT fixtures INTO database
    foreach my $table (keys %$data) {
        my $rs   = $schema->resultset($table);
        my @cols = @{$data->{$table}{columns}};
        
        foreach my $row (@{$data->{$table}{data}}) {
            my $i = 0;
            my $r = {};
            foreach my $col (@cols) {
                $r->{$col} = $row->[$i++];
            }
            $rs->create($r);
        }
    }
}

=head1 add_test_record($string, [$person, [$channel]])

Parse a string like it's an IRC message and add to the database

=cut

sub add_test_record {
    my $schema = shift;
    my $what   = shift;
    my $who    = shift || 'jrockway!~jrockway@foo.jrock.us';
    my $where  = shift || '#test';

    my $action = App::Ircxory::Robot::Parser::_parse_karma($who, $where, $what);
    
    if ($action) {
        $schema->record($action);
    }
    else {
        die 'parse error';
    }

    return;
}

1;
