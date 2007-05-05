package App::Ircxory::Schema::Nicknames;

# Created by DBIx::Class::Schema::Loader v0.03009 @ 2007-05-04 04:55:41

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("PK::Auto", "Core");
__PACKAGE__->table("nicknames");
__PACKAGE__->add_columns(
  "nid",
  { data_type => "INTEGER", is_nullable => 0, size => undef },
  "pid",
  { data_type => "INTEGER", is_nullable => 0, size => undef },
  "nick",
  { data_type => "TEXT", is_nullable => 0, size => undef },
  "username",
  { data_type => "TEXT", is_nullable => 0, size => undef },
  "host",
  { data_type => "TEXT", is_nullable => 0, size => undef },
);
__PACKAGE__->set_primary_key("nid");
__PACKAGE__->add_unique_constraint(
  hostmask => [qw/nick username host/]
);                                   
__PACKAGE__->has_many(
  "opinions",
  "App::Ircxory::Schema::Opinions",
  { "foreign.nid" => "self.nid" },
);
__PACKAGE__->belongs_to("person", "App::Ircxory::Schema::People", { pid => "pid" });

1;

