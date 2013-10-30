# Author: yingjie.liu@thomsonreuters.com
# DateTime: 2011-05-26 16:02:56

#=========examples===========
# my @date = (localtime)[3,4,5];
# $date[1]++;
# $date[2]+=1900;
# my $date = join "/", @date;

#begin



package Algorithm;
#use base qw(Exporter);
use warnings;
use strict;
use overload ('0+' => 'to_number',
				'""'=> 'as_string');
use Object;
use Statistics::Descriptive;

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
}

sub type {"Algo"}
#sub id { $_[0]->{id}=$_[1] if defined $_[1]; $_[0]->{id} }
#sub id { $_[0]->{id}=$_[1] if @_>1; $_[0]->{id} }

sub process {
	my $self = shift;
    my $queue=\$_[0]->input_queue;
    $self->logger->debug("$self is processing $$queue");
    my $output=$$queue->pop_front;
    return $output;

    return undef;
}

sub to_number{
	#return $_[0]->{'m_value'};
}

#sub as_string{
#	return "Algorithm";
#}
########################util function#####################
sub get_array_sd {#param: pointer of array
  my $stat = Statistics::Descriptive::Full->new();
  $stat->add_data(@{$_[0]}); 
  #return 0 if($stat->sum() < 10); 
  #return 0 if($_[0]->[0]>$_[0]->[1]+$_[0]->[2]);
  return sprintf("%.2f",$stat->standard_deviation()); 
  #return $stat->standard_deviation();
}

sub get_normal_array_sd {#param: pointer of array
  my $stat = Statistics::Descriptive::Full->new();
  $stat->add_data(@{$_[0]}); 
  #return 0 if($stat->sum() < 10); 
  #return 0 if($_[0]->[0]>$_[0]->[1]+$_[0]->[2]);
  return sprintf("%.4f",$stat->standard_deviation()/$stat->sum()); 
}

sub get_array_sum {#param: pointer of array
  my $stat = Statistics::Descriptive::Full->new();
  $stat->add_data(@{$_[0]}); 
  return sprintf("%.4f",$stat->sum()); 
}

sub get_array_within { #params: pointer of array, threshold
    my $c=0;
    my $prev=undef;
    foreach my $v (sort @{$_[0]}){
        unless (defined $prev){
            $prev=$v;
            next;
        }
        if($v-$prev < $_[1]){
            $c++;
        }
        $prev=$v;
    }
    return $c;
}
sub get_big_gap_count{ #params: pointer of array, threshold
    my $c=0;
    my $prev=undef;
    foreach my $v (sort @{$_[0]}){
        unless (defined $prev){
            $prev=$v;
            next;
        }
        if($v-$prev >= $_[1]){
            $c++;
        }
        $prev=$v;
    }
    return $c;
}
unless(caller){
#unit test code
#set_logfile(__PACKAGE__."_ut.log");
    Log::Log4perl->init("log.conf");
	my $obj=Algorithm->new;
	print "UT start for ".(ref $obj)."\n";
};



1;
