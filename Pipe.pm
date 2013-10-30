# Author: yingjie.liu@thomsonreuters.com
# DateTime: 2011-05-26 15:30:21

#=========examples===========
# my @date = (localtime)[3,4,5];
# $date[1]++;
# $date[2]+=1900;
# my $date = join "/", @date;

#begin



package Pipe;
#use base qw(Exporter);
use warnings;
use strict;
use overload ('0+' => 'to_number',
				'""'=> 'as_string');
use Object;
use SimpleQ;
use Flush;

our @ISA = qw(Object);
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
    $self->{input_queue}=SimpleQ->new;
    #$self->{algo}=Algorithm->new;
    $self->{buffering}=0;
}

sub type { "Pipe" }
sub input_queue { $_[0]->{input_queue}=$_[1] if defined $_[1]; $_[0]->{input_queue} }
sub next_pipe { $_[0]->{next_pipe}=$_[1] if @_>1; $_[0]->{next_pipe} }
sub algo { $_[0]->{algo}=$_[1] if @_>1; $_[0]->{algo} }
#sub id { $_[0]->{id}=$_[1] if @_>1; $_[0]->{id} }
sub buffering { &Object::attr(@_);}

sub on_recv {
	my $self = shift;
    my ($item)=@_;
    $self->logger->debug("$self recved $item");
    $self->input_queue->push_back($item);
    if($self->buffering == 1 and $item->id != Flush::id){
        $self->logger->debug("$self buffered ".$self->input_queue->count." items");
        return;
    }
    my $output=undef;
    if(defined $self->algo){
        $output=$self->algo->process($self);
    }else{
        $self->logger->warn("$self can't process $item due to no algo defined");
        return;
    }
    if(defined $output){
        $self->send($self->next_pipe,$output) ;
    }else{
        $self->logger->debug("$self has no output on_recv $item");
        return;
    }
}

sub send {
	my $self = shift;
    my ($pipe,$item)=@_;
    if(defined $pipe){
        $self->logger->debug("$self send $item to $pipe");
        $pipe->on_recv($item); 
    }else{
        $self->logger->warn("$self can't send $item due to no next pipe defined");
        return;
    }
}

sub brief {
	my $self = shift;
    print "brief of $self:\n";
    print "\tinput_queue: ".$self->input_queue."\n";
    print "\tnext_pipe: ".(defined $self->next_pipe?$self->next_pipe:"undef")."\n";
    print "\talgo: ".(defined $self->algo?$self->algo:"undef")."\n";
}

sub to_number{
	#return $_[0]->{'m_value'};
}

#sub as_string{
#	return "Pipe";
#}

unless(caller){
#unit test code
#set_logfile(__PACKAGE__."_ut.log");
    Log::Log4perl->init("log.conf");
	my $obj=Pipe->new;
    use Algorithm;
    use QLink;
	print "UT start for ".(ref $obj)."\n";
    $obj->algo(Algorithm->new);
    my $l1=QLink->new;
    $obj->on_recv($l1);
    my $p1=Pipe->new;
    $p1->algo(Algorithm->new);
    $obj->next_pipe($p1);
    $obj->brief;
    $obj->on_recv($l1);
    $p1->brief;
};



1;
