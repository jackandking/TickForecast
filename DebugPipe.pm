# Author: yingjie.liu@thomsonreuters.com
# DateTime: 2011-05-28 20:16:42

#=========examples===========
# my @date = (localtime)[3,4,5];
# $date[1]++;
# $date[2]+=1900;
# my $date = join "/", @date;

#begin



package DebugPipe;
#use base qw(Exporter);
use warnings;
use strict;
use overload ('0+' => 'to_number',
				'""'=> 'as_string');
use Pipe;

our @ISA = qw(Pipe);
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
#sub id { $_[0]->{id}=$_[1] if @_>1; $_[0]->{id} }

#sub brief {
#  my $self = shift;
#  print "brief of $self:\n";
#}

sub on_recv {
	my $self = shift;
    my ($item)=@_;
    $self->logger->debug("$self recved $item");
    $item->brief;
}


sub to_number{
	#return $_[0]->{'m_value'};
}

#sub as_string{
#	return "DebugPipe";
#}

unless(caller){
#unit test code
#set_logfile(__PACKAGE__."_ut.log");
    Log::Log4perl->init("log.conf");
	my $obj=DebugPipe->new;
	print "UT start for ".(ref $obj)."\n";
};



1;
