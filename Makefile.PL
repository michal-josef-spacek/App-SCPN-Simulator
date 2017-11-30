use lib 'inc';
use strict;
use warnings;

use inc::Module::Install;

# Definition.
abstract 'Class for scpn-simulator application.';
author 'Michal Josef Spacek <skim@cpan.org>';
author_requires 'English' => 0;
author_requires 'File::Object' => 0.05;
author_requires 'Test::More' => 0;
author_requires 'Test::NoWarnings' => 0;
author_requires 'Test::Pod' => 0;
author_requires 'Test::Pod::Coverage' => 0;
install_script 'bin/scpn-simulator';
license 'bsd';
name 'App-SCPN-Simulator';
perl_version 5.006002;
readme_from 'Simulator.pm';
recursive_author_tests('xt');
requires 'Class::Utils' => 0.03;
requires 'English' => 0;
requires 'File::Temp' => 0;
requires 'Getopt::Std' => 0;
requires 'Mojo::Exception' => 0;
requires 'SCPN::Engine::Simple' => 0;
requires 'SCPN::Schema::GraphViz' => 0;
requires 'Tk' => 0;
requires 'Tk::PNG' => 0;
resources 'bugtracker' => 'https://rt.cpan.org/Public/Dist/Display.html'.
	'?Name=App-SCPN-Simulator';
resources 'homepage' => 'https://github.com/tupinek/App-SCPN-Simulator';
resources 'repository' => 'git://github.com/tupinek/App-SCPN-Simulator';
test_requires 'English' => 0;
test_requires 'Test::More' => 0;
test_requires 'Test::NoWarnings' => 0;
tests_recursive;
version '0.01';

WriteAll();
