# Author: yingjie.liu@thomsonreuters.com
# DateTime: 2011-05-26 22:00:07

#=========examples===========
# my @date = (localtime)[3,4,5];
# $date[1]++;
# $date[2]+=1900;
# my $date = join "/", @date;

#begin



package Tick;
#use base qw(Exporter);
use warnings;
use strict;
use overload ('0+' => 'to_number',
				'""'=> 'as_string');
use Object;

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
    $self->price(0);
    $self->volume(0);
    $self->time(0);
}

sub init {
  my $self = shift;
  my $array= shift;
  $self->logger->debug("init $self with @$array");
  $self->time($array->[0]);
  $self->price($array->[1]);
  $self->volume($array->[2]);
}

sub price { $_[0]->{price}=$_[1] if defined $_[1]; $_[0]->{price} }
sub volume { $_[0]->{volume}=$_[1] if defined $_[1]; $_[0]->{volume} }
sub time { $_[0]->{time}=$_[1] if defined $_[1]; $_[0]->{time} }
#sub id { $_[0]->{id}=$_[1] if @_>1; $_[0]->{id} }

sub brief {
  my $self = shift;
  print "brief of $self:\n";
  print "\tprice: ".$self->price."\n";
  print "\tvolume: ".$self->volume."\n";
  print "\ttime: ".$self->time."\n";
}

sub detail {
  my  $self= shift;
  $self->logger->info("detail of $self:");
  $self->logger->info("\tprice: ".$self->price);
  $self->logger->info("\tvolume: ".$self->volume);
  $self->logger->info("\ttime: ".$self->time);
}

sub to_number{
	#return $_[0]->{'m_value'};
}

#sub as_string{
#	return "Tick";
#}

unless(caller){
#unit test code
#set_logfile(__PACKAGE__."_ut.log");
    Log::Log4perl->init("log.conf");
	my $obj=Tick->new;
	print "UT start for ".(ref $obj)."\n";
    $obj->time(CORE::time);
    $obj->brief;
};



1;
