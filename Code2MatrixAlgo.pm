# Author: yingjie.liu@thomsonreuters.com
# DateTime: 2011-06-11 18:16:18

#=========examples===========
# my @date = (localtime)[3,4,5];
# $date[1]++;
# $date[2]+=1900;
# my $date = join "/", @date;

#begin



package Code2MatrixAlgo;
#use base qw(Exporter);
use warnings;
use strict;
use overload ('0+' => 'to_number',
				'""'=> 'as_string');
use Algorithm;
use Matrix;

our @ISA = qw(Algorithm);
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

#sub brief {
#  my $self = shift;
#  print "brief of $self:\n";
#}

sub process {
    my $self = shift;
    my ($pipe)=@_;

    my $code=$pipe->input_queue->pop_front;
    $self->logger->debug("$self is processing $code in $pipe");
    my $base=$code->base;
    my $length=$code->length;
    my $matrix=$pipe->qmatrix;
    my $p_key=substr $code->base_value,0,$length-1;
    my $s_key=substr $code->base_value,$length-1,1;
    $matrix->add($p_key,$s_key,$code);
    my $m=Matrix->new;
    $m->space(Space->new);
    $m->qmatrix($pipe->qmatrix);
    $m->base($base);
    $m->length($length);
    return $m;
}
sub to_number{
	#return $_[0]->{'m_value'};
}

#sub as_string{
#	return "Code2MatrixAlgo";
#}

unless(caller){
#unit test code
#set_logfile(__PACKAGE__."_ut.log");
    Log::Log4perl->init("log.conf");
	my $obj=Code2MatrixAlgo->new;
	print "UT start for ".(ref $obj)."\n";
};



1;
