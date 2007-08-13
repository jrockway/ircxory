# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

package App::Ircxory::Schema::Session;
use strict;
use warnings;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('sessions');      

__PACKAGE__->add_column( id => { type => 'CHAR',
                                 size => '72',
                               }
                       );
__PACKAGE__->add_column( session_data => { type => 'TEXT' } );
__PACKAGE__->add_column( expires => { type => 'INTEGER' } );

__PACKAGE__->set_primary_key('id');

1;
