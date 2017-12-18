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
                "spring" : { "title" : "Spring" },
                "summer" : { "title" : "Summer" },
                "autumn" : { "title" : "Autumn" },
                "winter" : { "title" : "Winter" }
        },
        "events":{
                "t0":{
                        "title": "t0",
                        "class": "t0",
                        "input_edges":[
                                {"condition":"spring"}
                        ],
                        "output_edges":[
                                {"condition":"summer"}
                        ]
                },
                "t1":{
                        "title": "t1",
                        "class": "t1",
                        "input_edges":[
                                {"condition":"summer"}
                        ],
                        "output_edges":[
                                {"condition":"autumn"}
                        ]
                },
                "t2":{
                        "title": "t2",
                        "class": "t2",
                        "input_edges":[
                                {"condition":"autumn"}
                        ],
                        "output_edges":[
                                {"condition":"winter"}
                        ]
                },
                "t3":{
                        "title": "t3",
                        "class": "t3",
                        "input_edges":[
                                {"condition":"winter"}
                        ],
                        "output_edges":[
                                {"condition":"spring"}
                        ]
                }
        },
        "case":{
                "spring":{
                        "init_config_1":{"value":"bullet"}
                }
        }
}
END
my $temp_scenario = File::Temp->new->filename;
barf($temp_scenario, $scenario);

# Arguments.
@ARGV = (
        '-t',
        '-v',
        $temp_scenario,
);

# Run.
App::SCPN::Simulator->new->run;

# Application is running.