package App::Ircxory::Schema::Opinions;

# Created by DBIx::Class::Schema::Loader v0.03009 @ 2007-05-04 04:55:41

use strict;
use warnings;
use Carp;

use base 'DBIx::Class';

__PACKAGE__->load_components("ResultSetManager", "PK::Auto", "Core");
__PACKAGE__->table("opinions");
__PACKAGE__->add_columns(
  "oid",
  { data_type => "INTEGER", is_nullable => 0, size => undef },
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

=head2 highest_rated([$how_many [, $multiplier]])

Returns a resultset page of C<$how_many> highest rated items, or 10 if
not specified.  If C<$multiplier> is C<-1>, then the lowest-rated
items are returned instead.  (C<$multiplier> defaults to 1.)

   my @top_ten = $schema->resultset('Opinions')->highest_rated();
   my @bot_ten = $schema->resultset('Opinions')->highest_rated(10, -1);
   my @top_40  = $schema->resultset('Opinions')->highest_rated(40);
   ...

From there:

   my $first = @top_ten[0];
   say $first->thing->thing. ' has '. $first->total_points. ' points';

=cut

sub highest_rated :ResultSet {
    my $self  = shift;
    my $count = shift || 10;
    my $mult  = shift || 1;
    
    croak "bad multiplier $mult; use 1 or -1"
      if $mult != -1 && $mult != 1;
    
    my $sort = $mult > 0 ? 'DESC' : 'ASC';
    return $self->search({},
                         { '+select' => [{ SUM => 'points'}],
                           '+as'     => [qw/total_points/],
                           join      => ['thing'],
                           group_by  => 'thing.tid',
                           order_by  => "SUM(points) $sort",
                           rows      => $count,
                           page      => 1,
                         });
}

=head2 lowest_rated([$how_many])

Abbreviation for highest_rated($how_many, -1)

=cut

sub lowest_rated :ResultSet {
    shift->highest_rated((shift||10), -1);
}

      
__PACKAGE__->mk_group_accessors(column => 'total_points');

1;
