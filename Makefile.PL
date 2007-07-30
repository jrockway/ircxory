use inc::Module::Install;

name 'App-Ircxory';
all_from 'lib/App/Ircxory.pm';

requires 'POE::Component::IRC';
requires 'Catalyst::Runtime' => '5.7007';
requires 'Catalyst::Model::DBIC::Schema';
requires 'Template::Declare' => '0.25';
requires 'Catalyst::View::Template::Declare';
requires 'Catalyst::Action::RenderView';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Unicode';
requires 'Catalyst::Plugin::Session';
requires 'Catalyst::Plugin::Session::Store::DBIC';
requires 'Catalyst::Plugin::Session::State::Cookie';
requires 'Catalyst::Plugin::Authentication';
requires 'Catalyst::Plugin::Authentication::Credential::OpenID';
requires 'DBD::SQLite';
requires 'Log::Log4perl';
requires 'Class::Accessor';
requires 'Regexp::Common::balanced';
requires 'YAML';
requires 'Exporter';
requires 'Readonly';
requires 'List::Util';
requires 'List::MoreUtils';
requires 'Carp';
requires 'Catalyst::Controller::BindLex';

build_requires 'Test::More';
build_requires 'ok';
build_requires 'Test::Exception';
build_requires 'Directory::Scratch';
build_requires 'SQL::Translator'; # ->deploy

auto_install;
WriteAll;
