package App::Ircxory::Schema::Opinions;

# Created by DBIx::Class::Schema::Loader v0.03009 @ 2007-05-04 04:55:41

use strict;
use warnings;
use base 'DBIx::Class';

__PACKAGE__->load_components("PK::Auto", "Core");
__PACKAGE__->table("opinions");
__PACKAGE__->add_columns(
  "oid",
  { data_type => "INTEGER", is_nullable => 0, size => undef,
    is_auto_increment => 1,
  },
  "nid",
  { data_type => "INTEGER", is_nullable => 0, size => undef },
  "cid",
  { data_type => "INTEGER", is_nullable => 0, size => undef },
  "tid",
  { data_type => "INTEGER", is_nullable => 0, size => undef },
  "message",
  { data_type => "TEXT", is_nullable => 0, size => undef },
  "reason",
  { data_type => "TEXT", is_nullable => 0, size => undef },
  "points",
  { data_type => "INTEGER", is_nullable => 0, size => undef },
);
__PACKAGE__->set_primary_key("oid");
__PACKAGE__->belongs_to("nickname", "App::Ircxory::Schema::Nicknames", { nid => "nid" });
__PACKAGE__->belongs_to("thing", "App::Ircxory::Schema::Things", { tid => "tid" });
__PACKAGE__->belongs_to("channel", "App::Ircxory::Schema::Channels", { cid => "cid" });

=head1 EXTRA ACCESSORS

=head2 person

Returns nickname->person->name.

=cut

sub person {
    return $_[0]->nickname->person->name;
}

1;
