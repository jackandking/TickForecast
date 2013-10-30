# Author: yingjie.liu@thomsonreuters.com
# DateTime: 2011-05-24 16:49:37

#=========examples===========
# my @date = (localtime)[3,4,5];
# $date[1]++;
# $date[2]+=1900;
# my $date = join "/", @date;

#begin



package SimpleQSet;
#use base qw(Exporter);
use warnings;
use strict;
use overload ('0+' => 'to_number',
				'""'=> 'as_string');

use Object;
use SimpleQ;
our @ISA = qw( Object);
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
    $self->{set}={};
    $self->{count}=0;
}

sub count { $_[0]->{count}=$_[1] if defined $_[1]; $_[0]->{count} }
sub set { $_[0]->{set} }
sub empty {return $_[0]->{count} eq 0;}
#sub id { $_[0]->{id}=$_[1] if @_>1; $_[0]->{id} }

sub first_item { 
  my $self = shift;
  unless ($self->empty) {
      my $set=$self->set;
      my $queue;
      foreach my $key (keys %$set){
          $queue=$set->{$key};
          #$queue->head->item->brief;
          return $queue->head->item;
      }
  }
  return undef;
}

sub copy {
  my $self = shift;
  my $src_set= shift;
  $self->logger->debug("copy $src_set to $self");

  unless ($self->empty) {
      $self->logger->warn("$self is not empty, will be cleared!");
  }
  my $set=$src_set->set;
  foreach my $key (keys %$set){
      my $queue=\$self->{set}->{$key};
      unless (defined $$queue){
          $$queue=SimpleQ->new;
      }
      $$queue->copy($set->{$key});
  }
  $self->count($src_set->count);
}

sub to_number{
	#return $_[0]->{'m_value'};
}

#sub as_string{
#	return "SimpleQSet";
#}

sub brief {
  my $self = shift;
  $self->logger->info("brief of $self:");
  $self->logger->info("\tcount: ".$self->count);
  unless ($self->empty) {
      my $set=$self->set;
      my $queue;
      foreach my $key (keys %$set){
          $queue=$set->{$key};
          $self->logger->info("\t$key => $queue");
      }
  }
}

sub add {
  my $self = shift;
  my ($key,$item)=@_;
  my $queue=\$self->{set}->{$key};
  unless (defined $$queue){
      $$queue=SimpleQ->new;
  }
  #print "add $item\n";
  $$queue->push_back($item);
  #print "$$queue\n";
  $self->{count}++;
}

unless(caller){
#unit test code
#set_logfile(__PACKAGE__."_ut.log");
	my $obj=SimpleQSet->new;
	print "UT start for $obj\n";
    $obj->brief;
    use QLink;
    my $l1=QLink->new;
    $obj->add("$l1",$l1);
    $obj->brief;
    my $l2=QLink->new;
    $obj->add("$l1",$l2);
    $obj->brief;
};



1;
