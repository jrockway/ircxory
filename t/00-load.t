#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'App::Ircxory' );
}

diag( "Testing App::Ircxory $App::Ircxory::VERSION, Perl $], $^X" );
