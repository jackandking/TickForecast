# Author: yingjie.liu@thomsonreuters.com
# DateTime: 2011-06-08 10:42:28

#=========examples===========
# my @date = (localtime)[3,4,5];
# $date[1]++;
# $date[2]+=1900;
# my $date = join "/", @date;

#begin



package Divider;
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
    $self->next_pipes(SimpleQ->new);
}

#sub id { $_[0]->{id}=$_[1] if defined $_[1]; $_[0]->{id} }
#sub id { $_[0]->{id}=$_[1] if @_>1; $_[0]->{id} }
sub next_pipe { $_[0]->reg_pipe($_[1]) if @_>1; $_[0]->next_pipes->head->item }
sub next_pipes { $_[0]->{next_pipes}=$_[1] if @_>1; $_[0]->{next_pipes} }

sub reg_pipe {
	my $self = shift;
	my $pipe = shift;
    $self->logger->debug("registering $pipe into $self");
    if(defined $self->next_pipes->find($pipe)){
        $self->logger->warn("$pipe is already registered in $self!");
        return;
    }
    $self->next_pipes->push_back($pipe);
}

sub dereg_pipe {
	my $self = shift;
	my $pipe = shift;
    $self->logger->debug("deregistering $pipe into $self");
    $self->next_pipes->pop($pipe);
}

sub on_recv {
	my $self = shift;
    my ($item)=@_;
    $self->logger->debug("$self recved $item");
    $self->input_queue->push_back($item);
    $self->logger->debug("$self buffered ".$self->input_queue->count." items");
    my $output=undef;
    if(defined $self->algo){
        $output=$self->algo->process($self);
    }else{
        $self->logger->warn("$self can't process $item due to no algo defined");
        return;
    }
    if(defined $output){
        if($self->next_pipes->empty){
            $self->logger->warn("$self has no next pipe!");
            return;
        }
        my $itor=$self->next_pipes->head;
        while(defined $itor){
            $self->send($itor->item,$output) ;
            $itor=$itor->next;
        }
    }else{
        $self->logger->debug("$self has no output on_recv $item");
        return;
    }
}


sub to_number{
	#return $_[0]->{'m_value'};
}

#sub as_string{
#	return "Divider";
#}

unless(caller){
#unit test code
#set_logfile(__PACKAGE__."_ut.log");
    Log::Log4perl->init("log.conf");
	my $obj=Divider->new;
	print "UT start for ".(ref $obj)."\n";
};



1;
