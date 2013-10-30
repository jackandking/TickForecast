# Author: yingjie.liu@thomsonreuters.com
# DateTime: 2011-05-29 12:36:14

#=========examples===========
# my @date = (localtime)[3,4,5];
# $date[1]++;
# $date[2]+=1900;
# my $date = join "/", @date;

#begin



package Space;
#use base qw(Exporter);
use warnings;
use strict;
use overload ('0+' => 'to_number',
				'""'=> 'as_string');
use Object;
use SimpleQSet;

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
    $self->{qset}=SimpleQSet->new;
}

#sub id { $_[0]->{id}=$_[1] if defined $_[1]; $_[0]->{id} }
#sub id { $_[0]->{id}=$_[1] if @_>1; $_[0]->{id} }
sub qset { $_[0]->{qset}=$_[1] if @_>1; $_[0]->{qset} }
sub base { $_[0]->{base}=$_[1] if @_>1; $_[0]->{base} }
sub length { $_[0]->{length}=$_[1] if @_>1; $_[0]->{length} } #code length
sub empty { $_[0]->qset->empty }

sub copy {
	my $self = shift;
    $self->qset->copy($_[0]);
}

sub brief {
  my $self = shift;
  $self->logger->info("brief of $self:");
  $self->logger->info("base:". &_s($self->base));
  $self->logger->info("length:". &_s($self->length));
  $self->qset->brief;
}

sub to_number{
	#return $_[0]->{'m_value'};
}

#sub as_string{
#	return "Space";
#}

unless(caller){
#unit test code
#set_logfile(__PACKAGE__."_ut.log");
    Log::Log4perl->init("log.conf");
	my $obj=Space->new;
	print "UT start for ".(ref $obj)."\n";
};



1;
