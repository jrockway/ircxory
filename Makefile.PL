use inc::Module::Install;

name 'App-Ircxory';
all_from 'lib/App/Ircxory.pm';

requires 'POE::Component::IRC';
requires 'Catalyst::Runtime' => 5.7008;
requires 'Catalyst::Model::DBIC::Schema';
requires 'Catalyst::View::TT';
requires 'Catalyst::Action::RenderView';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Unicode';
requires 'DBD::SQLite';
requires 'Log::Log4perl';
requires 'Class::Accessor';
requires 'Regexp::Common::balanced';
requires 'YAML';
requires 'Exporter';
requires 'Readonly';
requires 'List::Util';
requires 'List::MoreUtils';

build_requires 'Test::More';
build_requires 'ok';

auto_install;
WriteAll;
