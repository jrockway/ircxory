# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

package App::Ircxory::Schema::Session;
use strict;
use warnings;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('sessions');
__PACKAGE__->add_columns(qw/id session_data expires/);
__PACKAGE__->set_primary_key('id');

1;
