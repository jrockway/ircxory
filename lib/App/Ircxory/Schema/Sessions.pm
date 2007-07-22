package App::Ircxory::Schema::Sessions;

# Created by DBIx::Class::Schema::Loader v0.03009 @ 2007-07-17 03:30:54

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("PK::Auto", "Core");
__PACKAGE__->table("sessions");
__PACKAGE__->add_columns(
  "id",
  { data_type => "CHAR", is_nullable => 0, size => 72 },
  "session_data",
  { data_type => "TEXT", is_nullable => 0, size => undef },
  "expires",
  { data_type => "INTEGER", is_nullable => 0, size => undef },
);
__PACKAGE__->set_primary_key("id");

1;

