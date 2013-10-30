# Author: yingjie.liu@thomsonreuters.com
# DateTime: 2011-06-19 13:20:59

#=========examples===========
# my @date = (localtime)[3,4,5];
# $date[1]++;
# $date[2]+=1900;
# my $date = join "/", @date;

#begin



package Item;
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

sub type {"Item"}
#sub id { $_[0]->{id}=$_[1] if defined $_[1]; $_[0]->{id} }
#sub id { $_[0]->{id}=$_[1] if @_>1; $_[0]->{id} }
sub data { &Object::attr(@_);}

#sub brief {
#  my $self = shift;
#  print "brief of $self:\n";
#}

sub to_number{
	#return $_[0]->{'m_value'};
}

#sub as_string{
#	return "Item";
#}

unless(caller){
#unit test code
#set_logfile(__PACKAGE__."_ut.log");
    Log::Log4perl->init("log.conf");
	my $obj=Item->new;
	print "UT start for ".(ref $obj)."\n";
};



1;
