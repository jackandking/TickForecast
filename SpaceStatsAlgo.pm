# Author: yingjie.liu@thomsonreuters.com
# DateTime: 2011-05-29 14:57:28

#=========examples===========
# my @date = (localtime)[3,4,5];
# $date[1]++;
# $date[2]+=1900;
# my $date = join "/", @date;

#begin



package SpaceStatsAlgo;
#use base qw(Exporter);
use warnings;
use strict;
use overload ('0+' => 'to_number',
				'""'=> 'as_string');
use Algorithm;
use Stats;
use Statistics::Descriptive;

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
}

#sub id { $_[0]->{id}=$_[1] if defined $_[1]; $_[0]->{id} }
#sub id { $_[0]->{id}=$_[1] if @_>1; $_[0]->{id} }
sub interval { $_[0]->{interval}=$_[1] if @_>1; $_[0]->{interval} }

#sub brief {
#  my $self = shift;
#  print "brief of $self:\n";
#}

sub process {
	my $self = shift;
    my $queue=$_[0]->input_queue;
    $self->logger->debug("$self is processing $queue");
    my $space=$queue->pop_front;
    my $stats=Stats->new;
    $stats->data($space);
    my $base=$space->base;
    my $length=$space->length;
    $stats->capacity($base ** $length);
    $stats->occupy(scalar keys %{$space->qset->set});
    $stats->ratio($stats->capacity>0?$stats->occupy/$stats->capacity:"undef");
    $stats->counter({});
    $stats->time_sd({});
    $stats->time_sep({});
    foreach my $key (keys %{$space->qset->set}){
        $stats->counter->{$key}=$space->qset->set->{$key}->count;
        my @times;
        for(my $itor=$space->qset->set->{$key}->head;
            defined $itor;
            $itor=$itor->next){
            push @times,$itor->item->time;
        }
        #$stats->time_sd->{$key}=&Algorithm::get_normal_array_sd(\@times);
        $stats->time_sd->{$key}=&Algorithm::get_array_sd(\@times);
        $stats->time_sep->{$key}=&Algorithm::get_big_gap_count(\@times,$self->interval);
    }
    return $stats;
}

sub to_number{
	#return $_[0]->{'m_value'};
}

#sub as_string{
#	return "SpaceStatsAlgo";
#}

unless(caller){
#unit test code
#set_logfile(__PACKAGE__."_ut.log");
    Log::Log4perl->init("log.conf");
	my $obj=SpaceStatsAlgo->new;
	print "UT start for ".(ref $obj)."\n";
};



1;
