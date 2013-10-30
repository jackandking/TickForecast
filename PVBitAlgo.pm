# Author: yingjie.liu@thomsonreuters.com
# DateTime: 2011-05-28 11:29:01

#=========examples===========
# my @date = (localtime)[3,4,5];
# $date[1]++;
# $date[2]+=1900;
# my $date = join "/", @date;

#begin



package PVBitAlgo;
#use base qw(Exporter);
use warnings;
use strict;
use overload ('0+' => 'to_number',
				'""'=> 'as_string');
use Algorithm;
use Bit;

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
#  my  = shift;
#  print "brief of :\n";
#}

sub process {
	my $self = shift;
    my $queue=\$_[0]->input_queue;
    $self->logger->debug("$self is processing $$queue");
    if($$queue->count > 1){
        my $new=$$queue->tail->item;
        my $old=$$queue->tail->prev->item;
        $$queue->pop_front;
        my $bit=Bit->new;
        $bit->queue->push_back($old);
        $bit->queue->push_back($new);
        $bit->base(9);
        #price  volume  bit
        #0      0       0
        #0      1       1
        #0      2       2
        #1      0       3
        #1      1       4
        #1      2       5
        #2      0       6
        #2      1       7
        #2      2       8
        my $volume=0;
        if($new->volume > $old->volume){
            $volume=1;
        }elsif($new->volume < $old->volume){
            $volume=2;
        }
        my $price=0;
        if($new->price > $old->price ){
            $price=1;
        }elsif($new->price < $old->price){
            $price=2;
        }
        $bit->base_value($price*3+$volume);
        return $bit;
    }else{
        return undef;
    }
}

sub to_number{
	#return $_[0]->{'m_value'};
}

#sub as_string{
#	return "BitAlgo";
#}

unless(caller){
#unit test code
#set_logfile(__PACKAGE__."_ut.log");
    Log::Log4perl->init("log.conf");
	my $obj=PVBitAlgo->new;
	print "UT start for ".(ref $obj)."\n";
    use BitModule;
    my $bm=BitModule->new;
    $bm->algo($obj);
    use Tick;
    my $t1=Tick->new;
    my $t2=Tick->new;
    use DebugPipe;
    $bm->next_pipe(DebugPipe->new);

    $t1->price(11);
    $t2->price(2);
    $t1->volume(100);
    $t2->volume(200);

    $bm->on_recv($t1);
    $bm->on_recv($t2);
};



1;
