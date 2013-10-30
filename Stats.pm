# Author: yingjie.liu@thomsonreuters.com
# DateTime: 2011-05-29 15:33:29

#=========examples===========
# my @date = (localtime)[3,4,5];
# $date[1]++;
# $date[2]+=1900;
# my $date = join "/", @date;

#begin



package Stats;
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
    $self->{data}=undef;
}

#sub id { $_[0]->{id}=$_[1] if defined $_[1]; $_[0]->{id} }
sub data { $_[0]->{data}=$_[1] if @_>1; $_[0]->{data} }
sub ratio { $_[0]->{ratio}=$_[1] if @_>1; $_[0]->{ratio} }
sub capacity { $_[0]->{capacity}=$_[1] if @_>1; $_[0]->{capacity} }
sub occupy { $_[0]->{occupy}=$_[1] if @_>1; $_[0]->{occupy} }
sub counter { $_[0]->{counter}=$_[1] if @_>1; $_[0]->{counter} }
sub ranked_counter { $_[0]->{ranked_counter}=$_[1] if @_>1; $_[0]->{ranked_counter} }
sub time_sd { $_[0]->{time_sd}=$_[1] if @_>1; $_[0]->{time_sd} }
sub ranked_time_sd { $_[0]->{ranked_time_sd}=$_[1] if @_>1; $_[0]->{ranked_time_sd} }
sub time_sep { $_[0]->{time_sep}=$_[1] if @_>1; $_[0]->{time_sep} }

sub brief {
  my $self = shift;
  $self->logger->info("brief of $self:");
  $self->logger->info("\tdata: ".$self->data."");
  $self->data->brief;
  $self->logger->info("\tcapacity: ".$self->capacity."");
  $self->logger->info("\toccupy: ".$self->occupy."");
  $self->logger->info("\tratio: ".$self->ratio."");
  $self->logger->info("\tcounter: ");
  #foreach my $key (sort {$a <=> $b} keys %{$self->counter}){
  foreach my $key (sort {$self->counter->{$b} <=> $self->counter->{$a}} keys %{$self->counter}){
      $self->logger->info("\t\tcounter: $key => ".$self->counter->{$key}."\ttime_sd: ".$self->time_sd->{$key}."\tsep: ".$self->time_sep->{$key});
  }
}

sub to_number{
	#return $_[0]->{'m_value'};
}

#sub as_string{
#	return "Stats";
#}

unless(caller){
#unit test code
#set_logfile(__PACKAGE__."_ut.log");
    Log::Log4perl->init("log.conf");
	my $obj=Stats->new;
	print "UT start for ".(ref $obj)."\n";
};



1;
