package App::Ircxory::Schema::Things;

# Created by DBIx::Class::Schema::Loader v0.03009 @ 2007-05-04 04:55:41

use strict;
use warnings;
use Carp;

use base 'DBIx::Class';
use App::Ircxory::ResultSet::Things;

__PACKAGE__->load_components("PK::Auto", "Core");
__PACKAGE__->table("things");
__PACKAGE__->add_columns(
  "tid",
  { data_type => "INTEGER", is_nullable => 0, size => undef,
    is_auto_increment => 1,
  },
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

__PACKAGE__->resultset_class('App::Ircxory::ResultSet::Things');

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

=head2 controversy

Return the controversy "score" from above two reports.

=head2 downs

count of downmods

=head2 ups

count of upmods

=cut

sub controversy { shift->get_column('controversy') }
sub downs       { shift->get_column('downs')       }
sub ups         { shift->get_column('ups')         }

1;
