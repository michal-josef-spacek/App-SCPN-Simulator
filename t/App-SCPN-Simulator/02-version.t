use strict;
use warnings;

use App::SCPN::Simulator;
use Test::More 'tests' => 2;
use Test::NoWarnings;

# Test.
is($App::SCPN::Simulator::VERSION, 0.01, 'Version.');
