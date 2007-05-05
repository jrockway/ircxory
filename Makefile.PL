use inc::Module::Install;

name 'App-Ircxory';
all_from 'lib/App/Ircxory.pm';

requires 'POE::Component::IRC';
requires 'Catalyst::Runtime' => 5.7008;
requires 'Catalyst::Model::DBIC::Schema';
requires 'DBD::SQLite';
requires 'Log::Log4perl';
requires 'Class::Accessor';
requires 'Regexp::Common::balanced';
requires 'YAML';
requires 'Exporter';
requires 'Readonly';

build_requires 'Test::More';

auto_install;
WriteAll;
