# Author: yingjie.liu@thomsonreuters.com
# DateTime: 2011-05-27 21:50:36

#=========examples===========
# my @date = (localtime)[3,4,5];
# $date[1]++;
# $date[2]+=1900;
# my $date = join "/", @date;

#begin



package TickAlgo;
#use base qw(Exporter);
use warnings;
use strict;
use overload ('0+' => 'to_number',
				'""'=> 'as_string');
use Algorithm;
use Tick;

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
    $self->{interval}=60;
    $self->{offset}=0;
    $self->{prev_volume}=0;
}

#sub interval { $_[0]->{interval}=$_[1] if defined $_[1]; $_[0]->{interval} }
#sub offset { $_[0]->{offset}=$_[1] if defined $_[1]; $_[0]->{offset} }
sub interval { my $attr=substr((caller(0))[3],rindex((caller(0))[3],"::")+2);$_[0]->{$attr}=$_[1] if @_>1; $_[0]->{$attr} }
sub offset { my $attr=substr((caller(0))[3],rindex((caller(0))[3],"::")+2);$_[0]->{$attr}=$_[1] if @_>1; $_[0]->{$attr} }
#sub prev_volume{ my $attr=substr((caller(0))[3],rindex((caller(0))[3],"::")+2);$_[0]->{$attr}=$_[1] if @_>1; $_[0]->{$attr} }
#sub prev_volume{ $_[0]->attr($_[1]);}
sub prev_volume{ &Object::attr(@_);}

#sub brief {
#  my  = shift;
#  print "brief of :\n";
#}
sub process {
	my $self = shift;
    my $queue=\$_[0]->input_queue;
    $self->logger->debug("$self is processing $$queue");
    if($self->offset > 0 and !$$queue->empty){
        my $oldest=$$queue->pop_front;
        $self->logger->debug("$oldest is ignored as offset ".$self->offset);
        $self->{offset}--;
        return undef;
    }
    if($$queue->count >= $self->interval){
        my $latest=$$queue->tail->item;
        $$queue->clear;
        my $tick=Tick->new;
        my $pv=$self->prev_volume;
        $self->prev_volume($latest->[2]);
        $latest->[2]-=$pv;
        $tick->init($latest);
        return $tick;
    }else{
        return undef;
    }
}

sub to_number{
	#return $_[0]->{'m_value'};
}

#sub as_string{
#	return "TickAlgo";
#}

unless(caller){
#unit test code
#set_logfile(__PACKAGE__."_ut.log");
    Log::Log4perl->init("log.conf");
	my $obj=TickAlgo->new;
	print "UT start for ".(ref $obj)."\n";
    use TickModule;
    my $tm=TickModule->new;
    $tm->algo($obj);
    use DebugPipe;
    $tm->next_pipe(DebugPipe->new);
    $obj->interval(1);
    $tm->on_recv([0,1,100]);
    $tm->on_recv([0,1,200]);
    $obj->brief;
};



1;
