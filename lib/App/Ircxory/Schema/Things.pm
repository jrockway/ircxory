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

1;

