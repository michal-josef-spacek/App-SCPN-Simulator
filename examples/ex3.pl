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
                "car_red" : { "title" : "RED for car" },
                "car_yellow" : { "title" : "YELLOW for car" },
                "car_green" : { "title" : "GREEN for car" },
                "p0" : { "title" : "" },
                "p1" : { "title" : "" },
                "person_green" : { "title" : "GREEN for person" },
                "person_red" : { "title" : "RED for person" }
        },
        "events":{
                "t0":{
                        "title": "",
                        "class": "t0",
                        "input_edges":[
                                {"condition":"car_green"}
                        ],
                        "output_edges":[
                                {"condition":"p0"},
                                {"condition":"car_red"}
                        ]
                },
                "t1":{
                        "title": "",
                        "class": "t1",
                        "input_edges":[
                                {"condition":"car_red"},
                                {"condition":"p1"}
                        ],
                        "output_edges":[
                                {"condition":"car_yellow"}
                        ]
                },
                "t2":{
                        "title": "",
                        "class": "t2",
                        "input_edges":[
                                {"condition":"car_yellow"}
                        ],
                        "output_edges":[
                                {"condition":"car_green"}
                        ]
                },
                "t3":{
                        "title": "",
                        "class": "t3",
                        "input_edges":[
                                {"condition":"p0"},
                                {"condition":"person_red"}
                        ],
                        "output_edges":[
                                {"condition":"person_green"}
                        ]
                },
                "t4":{
                        "title": "",
                        "class": "t4",
                        "input_edges":[
                                {"condition":"person_green"}
                        ],
                        "output_edges":[
                                {"condition":"person_red"},
                                {"condition":"p1"}
                        ]
                }
        },
        "case":{
                "car_red":{
                        "init_config_1":{"value":"bullet"}
                },
                "p0":{
                        "init_config_1":{"value":"bullet"}
                },
                "person_red":{
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