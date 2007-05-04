use inc::Module::Install;

name 'App-Ircxory';
all_from 'lib/App/Ircxory.pm';

build_requires 'Test::More';

auto_install;

WriteAll;

