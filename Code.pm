# Author: yingjie.liu@thomsonreuters.com
# DateTime: 2011-05-28 15:11:30

#=========examples===========
# my @date = (localtime)[3,4,5];
# $date[1]++;
# $date[2]+=1900;
# my $date = join "/", @date;

#begin



package Code;
#use base qw(Exporter);
use warnings;
use strict;
use overload ('0+' => 'to_number',
				'""'=> 'as_string');
use DerivedItem;

our @ISA = qw(DerivedItem);
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
sub length { $_[0]->{length}=$_[1] if defined $_[1]; $_[0]->{length} }
#sub id { $_[0]->{id}=$_[1] if @_>1; $_[0]->{id} }
sub h_time { $_[0]->queue->head->item->h_time }
sub t_time { $_[0]->queue->tail->item->t_time }
sub interval { $_[0]->{interval}=$_[1] if @_>1; $_[0]->{interval} }

sub calc_base_value {
	my $self = shift;
    my $base_value="";
    for(my $itor=$self->queue->head;defined $itor;$itor=$itor->next){
        $base_value.=$itor->item->base_value;
    }
    $self->base_value($base_value);
    return $base_value;
}


sub copy {
	my $self = shift;
    $self->queue->copy($_[0]);
    $self->base($self->queue->head->item->base);
    $self->calc_base_value;
    #my $base_value="";
    #for(my $itor=$self->queue->head;defined $itor;$itor=$itor->next){
    #    $base_value.=$itor->item->base_value;
    #}
    #$self->base_value($base_value);
}


sub to_number{
	#return $_[0]->{'m_value'};
}

sub as_string{
	return $_[0]->base_value;
}

unless(caller){
#unit test code
#set_logfile(__PACKAGE__."_ut.log");
    Log::Log4perl->init("log.conf");
	my $obj=Code->new;
	print "UT start for ".(ref $obj)."\n";
};



1;
