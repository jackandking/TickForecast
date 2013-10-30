# Author: yingjie.liu@thomsonreuters.com
# DateTime: 2011-05-27 21:38:27

#=========examples===========
# my @date = (localtime)[3,4,5];
# $date[1]++;
# $date[2]+=1900;
# my $date = join "/", @date;

#begin



package BitModule;
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
#  my  = shift;
#  print "brief of :\n";
#}

sub to_number{
	#return $_[0]->{'m_value'};
}

#sub as_string{
#	return "BitModule";
#}

unless(caller){
#unit test code
#set_logfile(__PACKAGE__."_ut.log");
    Log::Log4perl->init("log.conf");
	my $obj=BitModule->new;
	print "UT start for ".(ref $obj)."\n";
    use TickModule;
    my $tm=TickModule->new;
    use TickAlgo;
    my $algo=TickAlgo->new;
    $tm->algo($algo);
    $tm->next_pipe($obj);
    use BitAlgo;
    $obj->algo(BitAlgo->new);
    $obj->next_pipe(Pipe->new);
    $tm->process_db('..\trunk\ricmondat\__SSEC_20110503.db',"__SSEC_20110503",64);
};



1;
