package App::Ircxory::Schema::Things;

# Created by DBIx::Class::Schema::Loader v0.03009 @ 2007-05-04 04:55:41

use strict;
use warnings;

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

1;

