package App::Ircxory;

use warnings;
use strict;
use Catalyst qw(Static::Simple ConfigLoader Unicode);

our $VERSION = '0.01';
__PACKAGE__->config({ default_view => qr/App::Ircxory::View::TD$/,
                      name         => 'Ircxory',
                    });

__PACKAGE__->setup;

=head1 NAME

App::Ircxory - Social botworking 2.0

=head1 VERSION

Version 0.01

=head1 AUTHOR

Jonathan Rockway, C<< <jrockway at cpan.org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2007 Jonathan Rockway, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of App::Ircxory
