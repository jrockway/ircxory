package App::Ircxory::Schema::People;

# Created by DBIx::Class::Schema::Loader v0.03009 @ 2007-05-04 04:55:41

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("PK::Auto", "Core");
__PACKAGE__->table("people");
__PACKAGE__->add_columns(
  "pid",
  { data_type => "INTEGER", is_nullable => 0, size => undef, 
    is_auto_increment => 1, },
  "name",
  { data_type => "TEXT", is_nullable => 0, size => undef },
);
__PACKAGE__->set_primary_key("pid");
__PACKAGE__->add_unique_constraint(
  nickname => [qw/name/]
);                                   
__PACKAGE__->has_many(
  "nicknames",
  "App::Ircxory::Schema::Nicknames",
  { "foreign.pid" => "self.pid" },
);

1;

