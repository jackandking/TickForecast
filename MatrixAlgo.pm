# Author: yingjie.liu@thomsonreuters.com
# DateTime: 2011-06-03 18:04:37

#=========examples===========
# my @date = (localtime)[3,4,5];
# $date[1]++;
# $date[2]+=1900;
# my $date = join "/", @date;

#begin



package MatrixAlgo;
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
#sub id { $_[0]->{id}=$_[1] if @_>1; $_[0]->{id} }

#sub brief {
#  my $self = shift;
#  print "brief of $self:\n";
#}

sub process {
    my $self = shift;
    my ($pipe)=@_;
    $self->logger->debug("$self is processing $pipe");

    my $space=$pipe->input_queue->pop_front;
    my $base=$space->base;
    my $length=$space->length;
    my $set=$space->qset->set;
    my $matrix=Matrix->new;
    foreach my $key (keys %$set){
        my $queue=$set->{$key};
        my $p_key=substr $key,0,$length-1;
        my $s_key=substr $key,$length-1,1;
        $matrix->qmatrix->add_queue($p_key,$s_key,$queue);
    }
    $matrix->space($space);
    if($matrix->empty){
        return undef;
    }else{
        return $matrix;
    }
}

sub to_number{
	#return $_[0]->{'m_value'};
}

#sub as_string{
#	return "MatrixAlgo";
#}

unless(caller){
#unit test code
#set_logfile(__PACKAGE__."_ut.log");
    Log::Log4perl->init("log.conf");
	my $obj=MatrixAlgo->new;
	print "UT start for ".(ref $obj)."\n";
};



1;
