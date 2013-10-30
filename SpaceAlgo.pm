# Author: yingjie.liu@thomsonreuters.com
# DateTime: 2011-05-29 11:52:32

#=========examples===========
# my @date = (localtime)[3,4,5];
# $date[1]++;
# $date[2]+=1900;
# my $date = join "/", @date;

#begin



package SpaceAlgo;
#use base qw(Exporter);
use warnings;
use strict;
use overload ('0+' => 'to_number',
				'""'=> 'as_string');
use Algorithm;
use Space;
use Flush;

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

    if($pipe->input_queue->tail->item->id == Flush::id){
        $self->logger->info("Flush $pipe");
    }else{
        return undef;
    }

    #my $base=$pipe->input_queue->head->item->base;
    #my $length=$pipe->input_queue->head->item->length;
    while(!$pipe->input_queue->empty){
        my $code=$pipe->input_queue->pop_front;
        if($code->id != Flush::id){
            $pipe->qset->add($code->base_value,$code);
        }
    }
    if($pipe->qset->empty){
        return undef;
    }
    my $space=Space->new;
    $space->copy($pipe->qset);
    $space->base($pipe->qset->first_item->base);
    $space->length($pipe->qset->first_item->length);
    return $space;
}

sub to_number{
	#return $_[0]->{'m_value'};
}

#sub as_string{
#	return "SpaceAlgo";
#}

unless(caller){
#unit test code
#set_logfile(__PACKAGE__."_ut.log");
    Log::Log4perl->init("log.conf");
	my $obj=SpaceAlgo->new;
	print "UT start for ".(ref $obj)."\n";
};



1;
