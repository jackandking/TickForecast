# Author: yingjie.liu@thomsonreuters.com
# DateTime: 2011-05-28 15:12:20

#=========examples===========
# my @date = (localtime)[3,4,5];
# $date[1]++;
# $date[2]+=1900;
# my $date = join "/", @date;

#begin



package CodeAlgo;
#use base qw(Exporter);
use warnings;
use strict;
use overload ('0+' => 'to_number',
				'""'=> 'as_string');
use Algorithm;
use Code;

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
    $self->{length}=5;
}

sub length { $_[0]->{length}=$_[1] if defined $_[1]; $_[0]->{length} }
#sub id { $_[0]->{id}=$_[1] if @_>1; $_[0]->{id} }

#sub brief {
#  my  = shift;
#  print "brief of :\n";
#}

sub process {
    my $self = shift;
    my $queue=\$_[0]->input_queue;
    $self->logger->debug("$self is processing $$queue");
    if($self->length == $$queue->count){
        my $code=Code->new;
        $code->copy($$queue);
        $code->length($self->length);
        $$queue->pop_front;
        return $code;
    }elsif($self->length < $$queue->count){
        $self->logger->error("$$queue is too long");
        $$queue->clear;
    }else{
        $self->logger->debug("$$queue is waiting for more(".$self->length.") items");
    }
    return undef;
}

sub to_number{
	#return $_[0]->{'m_value'};
}

#sub as_string{
#	return "CodeAlgo";
#}

unless(caller){
#unit test code
#set_logfile(__PACKAGE__."_ut.log");
    Log::Log4perl->init("log.conf");
	my $obj=CodeAlgo->new;
	print "UT start for ".(ref $obj)."\n";
};



1;
