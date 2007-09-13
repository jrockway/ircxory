package App::Ircxory::View::TD;
use strict;
use warnings;

use base 'Catalyst::View::Template::Declare';

sub process {
    my $self = shift;
    my $c    = shift;
    $self->SUPER::process($c, @_);
    $c->res->{body} =~ s/^\n+//;
}
  


=head1 NAME

App::Ircxory::View::TD - Template::Declare View for App::Ircxory

=head1 DESCRIPTION

Template::Declare View for App::Ircxory. 

=head1 AUTHOR

Jonathan Rockway,,,

=head1 SEE ALSO

L<App::Ircxory>

=cut

1;
