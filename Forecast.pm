# Author: yingjie.liu@thomsonreuters.com
# DateTime: 2011-06-11 18:32:27

#=========examples===========
# my @date = (localtime)[3,4,5];
# $date[1]++;
# $date[2]+=1900;
# my $date = join "/", @date;

#begin



package Forecast;
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
}

#sub id { $_[0]->{id}=$_[1] if defined $_[1]; $_[0]->{id} }
sub content { $_[0]->{content}=$_[1] if @_>1; $_[0]->{content} }
sub cause { $_[0]->{cause}=$_[1] if @_>1; $_[0]->{cause} }
sub cause_time { $_[0]->{cause_time}=$_[1] if @_>1; $_[0]->{cause_time} }
sub cause_price { $_[0]->{cause_price}=$_[1] if @_>1; $_[0]->{cause_price} }
sub effect { $_[0]->{effect}=$_[1] if @_>1; $_[0]->{effect} }
sub effect_ratio { $_[0]->{effect_ratio}=$_[1] if @_>1; $_[0]->{effect_ratio} }
sub interval { $_[0]->{interval}=$_[1] if @_>1; $_[0]->{interval} }
sub counter { $_[0]->{counter}=$_[1] if @_>1; $_[0]->{counter} }
sub time_sd { $_[0]->{time_sd}=$_[1] if @_>1; $_[0]->{time_sd} }
sub time_sep { $_[0]->{time_sep}=$_[1] if @_>1; $_[0]->{time_sep} }

sub attri_info {
  my $self = shift;
  my $attri = shift;
  $self->logger->info("\t$attri: [".&_s($self->$attri)."]");
}
sub brief {
  my $self = shift;
  $self->logger->info("brief of $self:");
  $self->logger->info("\tcause_time: [".((defined $self->cause_time)?localtime($self->cause_time):"undef")."]");
  $self->attri_info("cause");
  $self->attri_info("cause_price");
  $self->attri_info("effect");
  $self->attri_info("effect_ratio");
  $self->attri_info("content");
  $self->attri_info("interval");
  $self->attri_info("counter");
  $self->attri_info("time_sd");
  $self->attri_info("time_sep");
}

sub to_number{
	#return $_[0]->{'m_value'};
}

#sub as_string{
#	return "Forecast";
#}

unless(caller){
#unit test code
#set_logfile(__PACKAGE__."_ut.log");
    Log::Log4perl->init("log.conf");
	my $obj=Forecast->new;
	print "UT start for ".(ref $obj)."\n";
};



1;
