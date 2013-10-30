# Author: yingjie.liu@thomsonreuters.com
# DateTime: 2011-05-28 11:58:26

#=========examples===========
# my @date = (localtime)[3,4,5];
# $date[1]++;
# $date[2]+=1900;
# my $date = join "/", @date;

#begin



package DerivedItem;
#use base qw(Exporter);
use warnings;
use strict;
use overload ('0+' => 'to_number',
				'""'=> 'as_string');
use Object;
use SimpleQ;

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
    $self->{queue}=SimpleQ->new;
}

sub queue { $_[0]->{queue}=$_[1] if defined $_[1]; $_[0]->{queue} }
sub base { $_[0]->{base}=$_[1] if @_>1; $_[0]->{base} }
sub base_value { $_[0]->{base_value}=$_[1] if @_>1; $_[0]->{base_value} }
sub dec_value { $_[0]->{dec_value}=$_[1] if @_>1; $_[0]->{dec_value} }
sub time { $_[0]->queue->head->item->time }

sub brief {
  my $self = shift;
  print "brief of $self:\n";
  print "\tqueue: ".$self->queue."\n";
  print "\tbase: ".$self->base."\n";
  print "\tbase_value: ".$self->base_value."\n";
}

sub detail {
  my  $self= shift;
  $self->logger->info("detail of $self:");
  $self->logger->info("\ttime:".$self->time);
  for(my $itor=$self->queue->head;defined $itor;$itor=$itor->next){
      $itor->item->detail;
  }
}

sub to_number{
	#return $_[0]->{'m_value'};
}

#sub as_string{
#	return "DerivedItem";
#}

unless(caller){
#unit test code
#set_logfile(__PACKAGE__."_ut.log");
    Log::Log4perl->init("log.conf");
	my $obj=DerivedItem->new;
	print "UT start for ".(ref $obj)."\n";
};



1;
