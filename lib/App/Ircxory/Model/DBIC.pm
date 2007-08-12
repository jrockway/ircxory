package App::Ircxory::Model::DBIC;

use strict;
use base 'Catalyst::Model::DBIC::Schema';
__PACKAGE__->config(
    schema_class => 'App::Ircxory::Schema',
);

sub ACCEPT_CONTEXT {
    my $self = shift;
    $self->NEXT::ACCEPT_CONTEXT(@_);
    return $self->schema;
}

=head1 NAME

App::Ircxory::Model::DBIC - Catalyst DBIC Schema Model
=head1 SYNOPSIS

See L<App::Ircxory>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using schema L<App::Ircxory::Schema>

=head1 AUTHOR

Jonathan Rockway,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
