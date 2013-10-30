# Author: yingjie.liu@thomsonreuters.com
# DateTime: 2011-05-22 18:47:48

#=========examples===========
# my @date = (localtime)[3,4,5];
# $date[1]++;
# $date[2]+=1900;
# my $date = join "/", @date;

#begin



package QLink;
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
sub next { $_[0]->{next}=$_[1] if @_>1; $_[0]->{next} }
sub prev { $_[0]->{prev}=$_[1] if @_>1; $_[0]->{prev} }
sub item { $_[0]->{item}=$_[1] if @_>1; $_[0]->{item} }

sub to_number{
	#return $_[0]->{'m_value'};
}

sub as_string{
	my $self = shift;
	return $self->item if defined $self->item;
	return "QLink<".$self->id.">";
    #return "QLink<".(defined $self->prev?$self->prev->id:"undef")."-".$self->id."-".(defined $self->next?$self->next->id:"undef").">";
}

sub brief {
	my $self = shift;
    print "brief of $self:\n";
    print "\tprev: ".(defined $self->prev?$self->prev->id:"undef")."\n";
    print "\tnext: ".(defined $self->next?$self->next->id:"undef")."\n";
    print "\titem: ".(defined $self->item?$self->item:"undef")."\n";
}

unless(caller){
#unit test code
#set_logfile(__PACKAGE__."_ut.log");
    Log::Log4perl->init("log.conf");
    my $null=QLink->new;
    my $obj=QLink->new;
    print "UT start for ".(ref $obj)."\n";
    my $obj1=QLink->new;
    $obj->next($obj1);
    $obj->brief;
};



1;
