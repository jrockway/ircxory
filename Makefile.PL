use inc::Module::Install;

name 'App-Ircxory';
all_from 'lib/App/Ircxory.pm';

requires 'Catalyst::Runtime' => 5.7008;
build_requires 'Test::More';

auto_install;

WriteAll;
