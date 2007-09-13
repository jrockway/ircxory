# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

package App::Ircxory::ResultSet::Things;
use strict;
use warnings;
use Carp;

use base 'DBIx::Class::ResultSet';

=head1 CUSTOM RESULTSETS

These methods are used by the C<Things> object to provide "reports"
based upon a resultset.

=head2 reasons_for($thing)

Return a resultset of opinions relating to C<$thing>.

=cut

sub reasons_for {
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

sub everything {
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

sub highest_rated {
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

sub lowest_rated {
    shift->highest_rated(shift(), -1);
}

=head2 most_controversial

Returns a ResultSet of Things ordered by "controversy".

=head2 least_controversial

Reversed.

=cut

sub most_controversial {
    my $self  = shift;
    my $count = shift;
    my $algo = '-(ABS(SUM(points))+COUNT(1))/(COUNT(1)-0.1)';
    $self->_controversial($count, $algo, 'DESC');
}

sub least_controversial {
    my $self  = shift;
    my $count = shift;
    my $algo = '-(ABS(SUM(points))+COUNT(1))/(COUNT(1)+0.8)';
    $self->_controversial($count, $algo, 'ASC');
}

sub _controversial {
    my $self  = shift;
    my $count = shift || 10;
    my $algo  = shift;
    my $order = shift;

    $algo .= ' co';

    return
      $self->search({},
                    { '+select' => [ \$algo,
                                     { SUM => 'points'},
                                     \'ABS(SUM((POINTS+1)/2))',
                                     \'ABS(SUM((POINTS-1)/2))',
                                     { COUNT => 1 },
                                   ],
                      '+as'     => [qw/controversy total_points ups downs c/],
                      join      => ['opinions'],
                      group_by  => 'me.tid',
                      order_by  => "co $order",
                      having    => "COUNT(1) > 5",
                      rows      => $count,
                      page      => 1,
                    });
}

1;
