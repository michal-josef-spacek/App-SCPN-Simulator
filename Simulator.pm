package App::SCPN::Simulator;

use strict;
use warnings;

use Class::Utils qw(set_params);
use English;
use File::Temp;
use Getopt::Std;
use Mojo::Exception;
use SCPN::Engine::Simple;
use SCPN::Schema::GraphViz;
use Tk;
use Tk::PNG;

our $VERSION = 0.01;

sub new {
	my ($class, @params) = @_;

	# Create object.
	my $self = bless {}, $class;

	# Process parameters.
	set_params($self, @params);

	# Process arguments.
	$self->{'_opts'} = {
		'h' => 0,
		'm' => undef,
		't' => 0,
		'v' => 0,
	};
	if (! getopts('hm:tv', $self->{'_opts'}) || @ARGV < 1
		|| $self->{'_opts'}->{'h'}) {

		print STDERR "Usage: $0 [-h] [-m macro_module] [-t] [-v] [--version] ".
			"scenario_config\n";
		print STDERR "\t-h\t\tHelp.\n";
		print STDERR "\t-m macro_module\tMacro module with implementation. ".
			"Without this module only simulate.\n";
		print STDERR "\t-t\t\tPrint titles.\n";
		print STDERR "\t-v\t\tVerbose mode.\n";
		print STDERR "\t--version\tPrint version.\n";
		print STDERR "\tscenario_config\tScenario configuration file\n";
		exit 1;
	}
	$self->{'_scenario_config'} = shift @ARGV;

	$self->{'engine'} = SCPN::Engine::Simple->new(
		schema_fpath => $self->{'_scenario_config'},
		verbose => $self->{'_opts'}->{'v'},
		actions => $self->_get_actions,
	);

	$self->{'image'} = File::Temp->new->filename.'.png';

	$self->{'graphviz'} = SCPN::Schema::GraphViz->new(
		$self->{'_opts'}->{'t'} ? ('print_titles' => 1) : (),
	);

	return $self;
}

sub run {
	my $self = shift;

	$self->{'mw'} = MainWindow->new;
	my $i = $self->{'mw'}->Photo('image',
		-file => $self->_get_actual_image_file,
	);
	$self->{'mw'}->Label(-image => $i)->pack;
	$self->{'mw'}->Button(
		'-text' => 'Play',
		'-command' => sub {
			while (1) {
				$self->_next_step;
			}
		},
	)->pack;
	$self->{'mw'}->Button(
		'-text' => 'Next step',
		'-command' => sub {
			$self->_next_step;
		},
	)->pack;
	MainLoop;

	return;
}

sub _get_actions {
	my $self = shift;
	if ($self->{'_opts'}->{'m'}) {
		eval "require $self->{'_opts'}->{'m'}";
		if ($EVAL_ERROR) {
			Mojo::Exception->throw('new: Cannot load '.
				$self->{'_opts'}->{'m'}.' module');
		}
		return $self->{'_opts'}->{'m'}->provided_actions,
	} else {
		return {};
	}
}

sub _get_actual_image_file {
	my $self = shift;
	$self->{'graphviz'}->to_png($self->{'engine'}->petri_net, $self->{'image'});
	return $self->{'image'};
}

sub _next_step {
	my $self = shift;
	print "next step\n" if $self->{'_opts'}->{'v'};

	$self->{'graphviz'}->to_png($self->{'engine'}->petri_net, $self->{'image'}, 1);
	my $image = $self->{'mw'}->Widget('image');
	$image->blank;
	$image->read($self->{'image'});
	$self->{'mw'}->update;

	$self->{'engine'}->run(1);

	$self->{'graphviz'}->to_png($self->{'engine'}->petri_net, $self->{'image'});
	$image = $self->{'mw'}->Widget('image');
	$image->blank;
	$image->read($self->{'image'});
	$self->{'mw'}->update;

	return;
}

1;

__END__

=pod

=encoding utf8

=head1 NAME

App::SCPN::Simulator - Base class for scpn-simulator script.

=head1 SYNOPSIS

 use App::SCPN::Simulator;

 my $app = App::SCPN::Simulator->new;
 $app->run;

=head1 METHODS

=over 8

=item C<new()>

 Constructor.

=item C<run()>

 Run method.
 Returns undef.

=back

=head1 ERRORS

 new():
         new: Cannot load %s module
         From Class::Utils::set_params():
                 Unknown parameter '%s'.

=head1 EXAMPLE1

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

=head1 EXAMPLE2

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

=head1 EXAMPLE3

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

=head1 DEPENDENCIES

L<Class::Utils>,
L<English>,
L<File::Temp>,
L<Getopt::Std>,
L<Mojo::Exception>,
L<SCPN::Engine::Simple>,
L<SCPN::Schema::GraphViz>,
L<Tk>,
L<Tk::PNG>.

=head1 AUTHOR

Michal Josef Špaček L<mailto:skim@cpan.org>

L<http://skim.cz>

=head1 LICENSE AND COPYRIGHT

© 2017-2022 Michal Josef Špaček

BSD 2-Clause License

=head1 VERSION

0.01

=cut
