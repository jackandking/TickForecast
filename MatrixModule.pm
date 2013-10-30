# Author: yingjie.liu@thomsonreuters.com
# DateTime: 2011-06-03 18:04:23

#=========examples===========
# my @date = (localtime)[3,4,5];
# $date[1]++;
# $date[2]+=1900;
# my $date = join "/", @date;

#begin



package MatrixModule;
#use base qw(Exporter);
use warnings;
use strict;
use overload ('0+' => 'to_number',
				'""'=> 'as_string');
use Pipe;
use SimpleQMatrix;

our @ISA = qw(Pipe);
#our @EXPORT=qw(debug);
#

#C'tor and initialisation
sub new {
	my $class = shift;
	my $self= {@_};
	bless($self, $class);
	$self->_init;
	return $self;
}

sub _init {
	my $self = shift;
	$self->SUPER::_init();
    $self->{qmatrix}=SimpleQMatrix->new;
}

#sub id { $_[0]->{id}=$_[1] if defined $_[1]; $_[0]->{id} }
#sub id { $_[0]->{id}=$_[1] if @_>1; $_[0]->{id} }
sub qmatrix { $_[0]->{qmatrix}=$_[1] if @_>1; $_[0]->{qmatrix} }

#sub brief {
#  my $self = shift;
#  print "brief of $self:\n";
#}

sub to_number{
	#return $_[0]->{'m_value'};
}

#sub as_string{
#	return "MatrixModule";
#}

unless(caller){
#unit test code
#set_logfile(__PACKAGE__."_ut.log");
    Log::Log4perl->init("log.conf");
	my $obj=MatrixModule->new;
	print "UT start for ".(ref $obj)."\n";
    use TickModule;
    my $tm=TickModule->new;
    use BitModule;
    my $bm=BitModule->new;
    use CodeModule;
    my $cm=CodeModule->new;
    use SpaceModule;
    my $sm=SpaceModule->new;
    $tm->next_pipe($bm);
    $bm->next_pipe($cm);
    $cm->next_pipe($sm);
    $sm->next_pipe($obj);
    use DebugPipe;
    $obj->next_pipe(DebugPipe->new);

    use TickAlgo;
    my $ta=TickAlgo->new;
    use BitAlgo;
    my $ba=BitAlgo->new;
    use CodeAlgo;
    my $ca=CodeAlgo->new;
    use SpaceAlgo;
    my $sa=SpaceAlgo->new;
    use MatrixAlgo;
    my $ma=MatrixAlgo->new;
    $tm->algo($ta);
    $bm->algo($ba);
    $cm->algo($ca);
    $sm->algo($sa);
    $obj->algo($ma);

    $tm->process_db('..\trunk\ricmondat\__SSEC_20110503.db',"__SSEC_20110503",-1);
    $sm->on_recv(Flush->new);
};



1;
