package App::Ircxory::Schema::Things;

# Created by DBIx::Class::Schema::Loader v0.03009 @ 2007-05-04 04:55:41

use strict;
use warnings;
use Carp;

use base 'DBIx::Class';

__PACKAGE__->load_components("ResultSetManager", "PK::Auto", "Core");
__PACKAGE__->table("things");
__PACKAGE__->add_columns(
  "tid",
  { data_type => "INTEGER", is_nullable => 0, size => undef },
  "thing",
  { data_type => "TEXT", is_nullable => 0, size => undef },
);
__PACKAGE__->set_primary_key("tid");
__PACKAGE__->add_unique_constraint(
  thing => [qw/thing/]
);                                   
__PACKAGE__->has_many(
  "opinions",
  "App::Ircxory::Schema::Opinions",
  { "foreign.tid" => "self.tid" },
);

=head2 total_points 

Return the sum of opinion points for a row in a Thing-containing resultset

=cut

sub total_points {
    my $self = shift;

    # if we've joined this in, use the version we already have
    my $fast = eval { $self->get_column('total_points') };
    return $fast if defined $fast;
    
    # if it's not there, compute it with another SQL query
    return $self->opinions->get_column('points')->sum;
}

=head1 CUSTOM RESULTSETS

=head2 reasons_for($thing)

Return a resultset of opinions relating to C<$thing>.

=cut

sub reasons_for :ResultSet {
    my $self   = shift;
    my $thing  = shift;
    
    return $self->
      search({ thing => $thing })->
        search_related(opinions => {reason => {'<>' => q{}}});
}

=head2 everything

Return everything, but also join in sum(points) to save hundreds
of queries

=cut

sub everything :ResultSet {
    my $self  = shift;
    my $query = shift || {};
    my $attrs = shift || {};
    
    return $self->search($query, { '+select' => { SUM => 'opinions.points' },
                                   '+as'     => 'total_points',
                                   join      => 'opinions',
                                   group_by  => 'opinions.tid',
                                   %$attrs,
                                 });
}

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
                         { '+select' => [{ SUM => 'opinions.points'}],
                           '+as'     => [qw/total_points/],
                           join      => ['opinions'],
                           group_by  => 'me.tid',
                           order_by  => "SUM(opinions.points) $sort",
                           rows      => $count,
                           page      => 1,
                         });
}

=head2 lowest_rated([$how_many])

Abbreviation for highest_rated($how_many, -1)

=cut

sub lowest_rated :ResultSet {
    shift->highest_rated(shift(), -1);
}

=head2 most_controversial

Returns a ResultSet of Things ordered by "controversy".

=cut

sub most_controversial :ResultSet {
    my $self = shift;
    my $count = shift || 10;
    my $mult  = shift || 1;
    
    croak "bad multiplier $mult; use 1 or -1"
      if $mult != -1 && $mult != 1;
    
    my $sort = $mult > 0 ? 'ASC' : 'DESC';
    
    return
      $self->search({},
                    { '+select' => [\'ABS(SUM(POINTS)*100)/COUNT(1) co'],
                      '+as'     => ['controversy'],
                      join      => ['opinions'],
                      group_by  => 'me.tid',
                      order_by  => "co $sort",
                      rows      => $count,
                      page      => 1,
                    });
}

=head2 least_controversial

Reversed.

=cut

sub least_controversial :ResultSet {
    shift->most_controversial(shift(), -1);
}

=head2 controversy

Return the controversy "score" from above two reports.

=cut

sub controversy {
    return shift->get_column('controversy');
}

1;
