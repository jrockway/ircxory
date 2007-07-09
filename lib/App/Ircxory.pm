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

=head1 BUGS

Please report any bugs or feature requests to
C<bug-app-ircxory at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=App-Ircxory>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc App::Ircxory

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/App-Ircxory>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/App-Ircxory>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=App-Ircxory>

=item * Search CPAN

L<http://search.cpan.org/dist/App-Ircxory>

=back

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Jonathan Rockway, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of App::Ircxory
