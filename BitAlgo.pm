# Author: yingjie.liu@thomsonreuters.com
# DateTime: 2011-05-28 11:29:01

#=========examples===========
# my @date = (localtime)[3,4,5];
# $date[1]++;
# $date[2]+=1900;
# my $date = join "/", @date;

#begin



package BitAlgo;
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
        $bit->base(3);
        if($new->price > $old->price){
            $bit->base_value(1);#up
        }elsif($new->price < $old->price){
            $bit->base_value(2);#down
        }else{
            $bit->base_value(0);#stable
        }
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
	my $obj=BitAlgo->new;
	print "UT start for ".(ref $obj)."\n";
};



1;
