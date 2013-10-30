# Author: yingjie.liu@thomsonreuters.com
# DateTime: 2011-06-03 18:04:52

#=========examples===========
# my @date = (localtime)[3,4,5];
# $date[1]++;
# $date[2]+=1900;
# my $date = join "/", @date;

#begin



package MatrixStatsAlgo;
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
sub interval { $_[0]->{interval}=$_[1] if @_>1; $_[0]->{interval} }

#sub brief {
#  my $self = shift;
#  print "brief of $self:\n";
#}

sub process {
	my $self = shift;
    my $queue=$_[0]->input_queue;
    $self->logger->debug("$self is processing $queue");
    my $matrix=$queue->pop_front;
    my $stats=Stats->new;
    $stats->data($matrix);
    my $base=$matrix->base;
    my $length=$matrix->length;
    $stats->capacity($base ** ($length-1));
    $stats->occupy(scalar keys %{$matrix->qmatrix->matrix});
    $stats->ratio($stats->capacity>0?$stats->occupy/$stats->capacity:"undef");
    $stats->counter({});
    $stats->time_sd({});
    $stats->time_sep({});
    my $map1= $matrix->qmatrix->matrix;
    foreach my $p_key (keys %{$map1}){
        my $c=0;
        my @times;
        foreach my $s_key (keys %{$map1->{$p_key}}){
            my $queue=$map1->{$p_key}->{$s_key};
            $c+=$queue->count;
            for(my $itor=$queue->head;
                defined $itor;
                $itor=$itor->next){
                push @times,$itor->item->time;
            }
        }
        $stats->counter->{$p_key}=$c;
        #$stats->time_sd->{$key}=&Algorithm::get_normal_array_sd(\@times);
        $stats->time_sd->{$p_key}=&Algorithm::get_array_sd(\@times);
        $stats->time_sep->{$p_key}=&Algorithm::get_big_gap_count(\@times,$self->interval);
    }
    return $stats;
}

sub to_number{
	#return $_[0]->{'m_value'};
}

#sub as_string{
#	return "MatrixStatsAlgo";
#}

unless(caller){
#unit test code
#set_logfile(__PACKAGE__."_ut.log");
    Log::Log4perl->init("log.conf");
	my $obj=MatrixStatsAlgo->new;
	print "UT start for ".(ref $obj)."\n";
};



1;
