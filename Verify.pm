# Author: yingjie.liu@thomsonreuters.com
# DateTime: 2011-06-12 13:59:12

#=========examples===========
# my @date = (localtime)[3,4,5];
# $date[1]++;
# $date[2]+=1900;
# my $date = join "/", @date;

#begin



package Verify;
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
sub data { $_[0]->{data}=$_[1] if @_>1; $_[0]->{data} }
sub result { $_[0]->{result}=$_[1] if @_>1; $_[0]->{result} }
sub hit { $_[0]->{hit}=$_[1] if @_>1; $_[0]->{hit} }
sub miss { $_[0]->{miss}=$_[1] if @_>1; $_[0]->{miss} }
sub ratio {
    my $self = shift;
    if(defined $self->hit and defined $self->miss and $self->miss > 0){
        return sprintf("%.2f",$self->hit/$self->miss);
    }else{
        return "undef";
    }
}

sub brief {
  my $self = shift;
  $self->logger->info("brief of $self:");
  $self->data->brief;
  $self->logger->info(localtime($self->data->cause_time)." result:".$self->result." hit:miss=(".&_s($self->hit).":".&_s($self->miss)."=".$self->ratio.")");
}

#sub to_number{
#	#return $_[0]->{'m_value'};
#}

#sub as_string{
#	return "Verify";
#}

unless(caller){
#unit test code
#set_logfile(__PACKAGE__."_ut.log");
    Log::Log4perl->init("log.conf");
	my $obj=Verify->new;
	print "UT start for ".(ref $obj)."\n";
};



1;
