# Author: yingjie.liu@thomsonreuters.com
# DateTime: 2011-05-28 15:12:14

#=========examples===========
# my @date = (localtime)[3,4,5];
# $date[1]++;
# $date[2]+=1900;
# my $date = join "/", @date;

#begin



package CodeModule;
#use base qw(Exporter);
use warnings;
use strict;
use overload ('0+' => 'to_number',
				'""'=> 'as_string');
use Divider;

our @ISA = qw(Divider);
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
#  my  = shift;
#  print "brief of :\n";
#}

sub to_number{
	#return $_[0]->{'m_value'};
}

#sub as_string{
#	return "CodeModule";
#}

unless(caller){
#unit test code
#set_logfile(__PACKAGE__."_ut.log");
    Log::Log4perl->init("log.conf");
	my $obj=CodeModule->new;
	print "UT start for ".(ref $obj)."\n";
    use TickModule;
    my $tm=TickModule->new;
    use BitModule;
    my $bm=BitModule->new;
    $tm->next_pipe($bm);
    $bm->next_pipe($obj);
    use DebugPipe;
    $obj->next_pipe(DebugPipe->new);

    use TickAlgo;
    my $ta=TickAlgo->new;
    use BitAlgo;
    my $ba=BitAlgo->new;
    use CodeAlgo;
    my $ca=CodeAlgo->new;
    $tm->algo($ta);
    $bm->algo($ba);
    $obj->algo($ca);

    $tm->process_db('..\trunk\ricmondat\__SSEC_20110503.db',"__SSEC_20110503",1124);
};



1;
