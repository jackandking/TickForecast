# Author: yingjie.liu@thomsonreuters.com
# DateTime: 2011-06-03 18:04:29

#=========examples===========
# my @date = (localtime)[3,4,5];
# $date[1]++;
# $date[2]+=1900;
# my $date = join "/", @date;

#begin



package Matrix;
#use base qw(Exporter);
use warnings;
use strict;
use overload ('0+' => 'to_number',
				'""'=> 'as_string');
use Object;
use SimpleQMatrix;

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
    $self->{qmatrix}=SimpleQMatrix->new;
}

#sub id { $_[0]->{id}=$_[1] if defined $_[1]; $_[0]->{id} }
sub qmatrix { $_[0]->{qmatrix}=$_[1] if @_>1; $_[0]->{qmatrix} }
sub space { $_[0]->{space}=$_[1] if @_>1; $_[0]->{space} }
sub base { $_[0]->{base}=$_[1] if @_>1; $_[0]->{base} }
sub length { $_[0]->{length}=$_[1] if @_>1; $_[0]->{length} } #code length
sub empty { $_[0]->qmatrix->empty }

sub brief {
  my $self = shift;
  $self->logger->info("brief of $self:");
  $self->space->brief;
  $self->qmatrix->brief;
}

sub to_number{
	#return $_[0]->{'m_value'};
}

#sub as_string{
#	return "Matrix";
#}

unless(caller){
#unit test code
#set_logfile(__PACKAGE__."_ut.log");
    Log::Log4perl->init("log.conf");
	my $obj=Matrix->new;
	print "UT start for ".(ref $obj)."\n";
};



1;
