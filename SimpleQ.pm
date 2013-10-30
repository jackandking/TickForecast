# Author: yingjie.liu@thomsonreuters.com
# DateTime: 2011-05-22 20:30:40

#=========examples===========
# my @date = (localtime)[3,4,5];
# $date[1]++;
# $date[2]+=1900;
# my $date = join "/", @date;

#begin



package SimpleQ;
#use base qw(Exporter);
use warnings;
use strict;
use overload ('0+' => 'to_number',
  '""'=> 'as_string');
use Object;
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
  $self->{count}=0;
  $self->SUPER::_init();
}

sub id { $_[0]->{id}=$_[1] if defined $_[1]; $_[0]->{id} }
sub head { $_[0]->{head}=$_[1] if @_>1; $_[0]->{head} }
sub tail { $_[0]->{tail}=$_[1] if @_>1; $_[0]->{tail} }
sub count { $_[0]->{count}=$_[1] if defined $_[1]; $_[0]->{count} }
sub empty {return $_[0]->{count} eq 0;}

sub clear {
  my $self = shift;
  $self->logger->debug("clear $self");
  while(!$self->empty){
      $self->pop_front;
  }
}

sub copy {
  my $self = shift;
  my $src_queue= shift;
  $self->logger->debug("copy $src_queue to $self");
  unless($self->empty){
      $self->logger->warn("$self is not empty, will be cleared!");
      $self->clear;
  }
  my $itor=$src_queue->head;
  while(defined $itor){
      $self->push_back($itor->item);
      $itor=$itor->next;
  }
}

sub find {
  my $self = shift;
  my $item= shift;
  $self->logger->debug("find $item from $self");
  if($self->empty){
      $self->logger->warn("$self is empty!");
      return undef;
  }
  my $itor=$self->head;
  while(defined $itor){
      if($itor->item->id eq $item->id){
          return $itor;#found
      }
      $itor=$itor->next;
  }
  return undef;#not found
}

sub link {
  my ($self, $item) = @_;
  $self->logger->debug("link $item to $self");
  if(defined $self->tail){
    $self->tail->next($item);
    $item->prev($self->tail);
    $self->tail($item);
  }else{
    $self->tail($item);
    $self->head($item);
  }
  $self->{count}++;
}

sub unlink {
  my ($self, $item) = @_;
  if($self->empty){
      $self->logger->debug("unlink $item from $self failed due to Q is empty");
      return undef;
  }
  if(defined $item->prev){#not head
    $item->prev->next($item->next);
    if(defined $item->next){#not tail
      $item->next->prev($item->prev);
    }else{#is tail
      $self->tail($item->prev);
    }
  }else{#is head
    $self->head($item->next);
    if(defined $item->next){#not tail
      $item->next->prev(undef);
    }else{#is tail
      $self->tail(undef);
    }
  }
  $item->prev(undef);
  $item->next(undef);
  $self->{count}--;
  return $item;
}

sub push_back { 
    my $self = shift;
    my $item = shift;
    $self->logger->debug("push_back $item to $self");
    my $node=QLink->new;
    $node->item($item);
    $self->link($node); 
}

sub pop {
  my $self = shift;
  my $item = shift;
  $self->logger->debug("pop $item from $self");
  if($self->empty){
      $self->logger->warn("nothing to pop from $self");
      return undef ;
  }
  my $itor=$self->find($item);
  $self->unlink($itor) if defined $itor;
}

sub pop_front {
  my $self = shift;
  $self->logger->debug("pop_front from $self");
  if($self->empty){
      $self->logger->warn("nothing to pop from $self");
      return undef ;
  }
  my $head=$self->head;
  $self->unlink($head);
  return $head->item;

  #another implementation incase unlink can't work.
  if(defined $head->next){
    $head->next->prev(undef);
    $self->head($head->next);
    $self->{count}--;
    $head->next(undef);
  }else{#also is the tail
    $self->head(undef);
    $self->tail(undef);
    $self->{count}=0;
  }
  return $head;
}

sub to_number{
  #return $_[0]->{'m_value'};
}

sub as_string{
  my $self = shift;
  my $name=$self->SUPER::as_string();
  if($self->empty) {
      return "${name}[".$self->count."]";
  }else{
      return "${name}[".$self->count.":".$self->head."..".$self->tail."]";
  }
}

sub brief {
  my $self = shift;
  print "brief of $self:\n";
  print "\tcount: ".$self->count."\n";
  unless ($self->empty) {
    print "\thead: ".$self->head."\n";
    print "\ttail: ".$self->tail."\n";
  }
}

sub detail {
  my  $self= shift;
  $self->logger->info("detail of $self:");
  for(my $itor=$self->head;defined $itor;$itor=$itor->next){
      $itor->item->detail;
  }
}

unless(caller){
#unit test code
#set_logfile(__PACKAGE__."_ut.log");
    Log::Log4perl->init("log.conf");
    my $obj=SimpleQ->new;
    $obj->logger->info("UT start for $obj");
    $obj->brief;
    use QLink;
    my $l1=QLink->new;
    my $l2=QLink->new;
    $obj->push_back($l1);
    $obj->brief;
    $obj->push_back($l2);
    $obj->brief;
    my $l3=$obj->pop_front;
    $l3->brief;
    $obj->brief;
    $obj->push_back(QLink->new);
    $obj->push_back(QLink->new);
    $obj->push_back(QLink->new);
    $obj->push_back(QLink->new);
    $obj->push_back(QLink->new);
    $obj->brief;
    $l3=$obj->pop_front;
    $l3->brief;
    $obj->brief;
    $l3=$obj->pop_front;
    $l3=$obj->pop_front;
    $l3=$obj->pop_front;
    $l3=$obj->pop_front;
    $obj->head->brief;
    $l3=$obj->pop_front;
    $l3->brief;
    $l3=$obj->pop_front;
};



1;
