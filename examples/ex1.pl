#!/usr/bin/env perl

use strict;
use warnings;

use App::SCPN::Simulator;
use File::Temp;
use IO::Barf qw(barf);

# Scenario.
my $scenario = <<'END';
{
        "conditions": {
                "in_1" : { "title" : "First input" },
                "in_2" : { "title" : "Second input" },
                "in_3" : { "title" : "Third input" },
                "out" : { "title" : "Output" }
        },
        "events":{
                "run":{
                        "title": "Run",
                        "class": "run",
                        "input_edges":[
                                {"condition":"in_1"},
                                {"condition":"in_2","count":2},
                                {"condition":"in_3","count":2}
                        ],
                        "output_edges":[
                                {"condition":"out"}
                        ]
                }
        },
        "case":{
                "in_1":{
                        "init_config_1":{"value":"bullet"},
                        "init_config_2":{"value":"bullet"}
                },
                "in_2":{
                        "init_config_1":{"value":"bullet"},
                        "init_config_2":{"value":"bullet"}
                },
                "in_3":{
                        "init_config_1":{"value":"bullet"},
                        "init_config_2":{"value":"bullet"},
                        "init_config_3":{"value":"bullet"}
                },
                "out":{
                        "init_config":{"value":"bullet"}
                }
        }
}
END
my $temp_scenario = File::Temp->new->filename;
barf($temp_scenario, $scenario);

# Arguments.
@ARGV = (
        '-v',
        $temp_scenario,
);

# Run.
App::SCPN::Simulator->new->run;

# Application is running.