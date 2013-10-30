# Author: yingjie.liu@thomsonreuters.com
# DateTime: 2011-06-12 13:48:40

#=========examples===========
# my @date = (localtime)[3,4,5];
# $date[1]++;
# $date[2]+=1900;
# my $date = join "/", @date;

#begin



package VerifyModule;
#use base qw(Exporter);
use warnings;
use strict;
use overload ('0+' => 'to_number',
				'""'=> 'as_string');
use Pipe;

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
}

#sub id { $_[0]->{id}=$_[1] if defined $_[1]; $_[0]->{id} }
#sub id { $_[0]->{id}=$_[1] if @_>1; $_[0]->{id} }

#sub brief {
#  my $self = shift;
#  print "brief of $self:\n";
#}

sub to_number{
	#return $_[0]->{'m_value'};
}

#sub as_string{
#	return "VerifyModule";
#}

unless(caller){
#unit test code
#set_logfile(__PACKAGE__."_ut.log");
    Log::Log4perl->init("log.conf");
	my $obj=VerifyModule->new;
	print "UT start for ".(ref $obj)."\n";
    use TickModule;
    my $tm=TickModule->new;
    use BitModule;
    my $bm=BitModule->new;
    use CodeModule;
    my $cm=CodeModule->new;
    use MatrixModule;
    my $mm=MatrixModule->new;
    use StatsModule;
    my $sm=StatsModule->new;
    use ForecastModule;
    my $fm=ForecastModule->new;
    $tm->next_pipe($bm);
    $bm->next_pipe($cm);
    $cm->reg_pipe($mm);
    $mm->next_pipe($sm);
    $sm->next_pipe($fm);
    $cm->reg_pipe($fm);
    $fm->next_pipe($obj);
    use DebugPipe;
    $obj->next_pipe(DebugPipe->new);

    use TickAlgo;
    my $ta=TickAlgo->new;
    use BitAlgo;
    my $ba=BitAlgo->new;
    use CodeAlgo;
    my $ca=CodeAlgo->new;
    use Code2MatrixAlgo;
    my $c2ma=Code2MatrixAlgo->new;
    use MatrixStatsAlgo;
    my $msa=MatrixStatsAlgo->new;
    use ForecastAlgo;
    my $fa=ForecastAlgo->new;
    use VerifyAlgo;
    my $va=VerifyAlgo->new;
    #$fa->qmatrix($mm->qmatrix);
    $tm->algo($ta);
    $bm->algo($ba);
    $cm->algo($ca);
    $mm->algo($c2ma);
    $sm->algo($msa);
    $fm->algo($fa);
    $obj->algo($va);

    $fa->threshold->{counter}=10;
    $fa->interval($ta->interval);
    $va->dbfile('..\poc\ricmondat\__SSEC_20110503.db');
    $va->table("__SSEC_20110503");
    $va->open_db;

    $tm->process_db('..\poc\ricmondat\__SSEC_20110503.db',"__SSEC_20110503",10000);
};



1;
