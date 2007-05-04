use inc::Module::Install;

name 'App-Ircxory';
all_from 'lib/App/Ircxory.pm';

requires 'POE::Component::IRC';
requires 'Catalyst::Runtime' => 5.7008;
requires 'Log::Log4perl';
requires 'YAML';

build_requires 'Test::More';

auto_install;

WriteAll;
