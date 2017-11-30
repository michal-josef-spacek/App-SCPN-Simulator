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
	$self->{'engine'}->run(1);
	$self->{'graphviz'}->to_png($self->{'engine'}->petri_net, $self->{'image'});
	my $image = $self->{'mw'}->Widget('image');
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

=head1 EXAMPLE

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

 © 2017 Michal Josef Špaček
 BSD 2-Clause License

=head1 VERSION

0.01

=cut
