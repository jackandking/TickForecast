# Author: yingjie.liu@thomsonreuters.com
# DateTime: 2011-05-24 21:58:05

#=========examples===========
# my @date = (localtime)[3,4,5];
# $date[1]++;
# $date[2]+=1900;
# my $date = join "/", @date;

#begin



package SimpleQMatrix;
#use base qw(Exporter);
use warnings;
use strict;
use overload ('0+' => 'to_number',
				'""'=> 'as_string');
use Object;
use SimpleQ;

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
    $self->{matrix}={};
    $self->{count}=0;
}

#sub id { $_[0]->{id}=$_[1] if defined $_[1]; $_[0]->{id} }
sub matrix { $_[0]->{matrix} }
sub count { $_[0]->{count}=$_[1] if defined $_[1]; $_[0]->{count} } #queue count

sub add {
	my $self = shift;
    my ($p_key,$s_key,$item)=@_;
    my $set=\$self->{matrix}->{$p_key};
    unless (defined $$set) {
        $$set={} ;
        #$self->{count}++;
    }
    my $queue=\$$set->{$s_key};
    unless (defined $$queue){
        $$queue=SimpleQ->new; 
        $self->{count}++;
    }
    $$queue->push_back($item);
}

sub add_queue {
	my $self = shift;
    my ($p_key,$s_key,$s_queue)=@_;
    my $set=\$self->{matrix}->{$p_key};
    unless (defined $$set) {
        $$set={} ;
        #$self->{count}++;
    }
    my $queue=\$$set->{$s_key};
    unless (defined $$queue){
        $self->{count}++;
    }
    $$queue=$s_queue;
}

sub empty { return $_[0]->count eq 0; }

sub clear{
    my $self = shift;
    $self->logger->info("clear $self:");
    unless ($self->empty) {
        my $matrix=$self->matrix;
        foreach my $p_key (keys %$matrix){
            my $set=$matrix->{$p_key};
            foreach my $s_key (keys %$set){
                my $queue=$set->{$s_key};
                $queue->clear;
                delete $set->{$s_key};
            }
            delete $matrix->{$p_key};
        }
    }
    $self->{count}=0;
}

sub brief {
    my $self = shift;
    $self->logger->info("brief of $self:");
    $self->logger->info("\tcount: ".$self->count);
    unless ($self->empty) {
        my $matrix=$self->matrix;
        foreach my $p_key (keys %$matrix){
            my $set=$matrix->{$p_key};
            $self->logger->info("\t$p_key => ");
            foreach my $s_key (keys %$set){
                my $queue=$set->{$s_key};
                $self->logger->info("\t\t$s_key => $queue");
            }
        }
    }
}

sub to_number{
	#return $_[0]->{'m_value'};
}

#sub as_string{
#	return "SimpleQMatrix";
#}

unless(caller){
#unit test code
#set_logfile(__PACKAGE__."_ut.log");
	my $obj=SimpleQMatrix->new;
	$obj->logger->info("UT start for ".(ref $obj));
    use QLink;
    my $l1=QLink->new;
    my $l2=QLink->new;
    my $l3=QLink->new;
    $obj->add("$l1","$l2",$l3);
    $obj->brief;
    my $l4=QLink->new;
    $obj->add("$l1","$l2",$l4);
    $obj->brief;
    $obj->add("$l1","$l3",$l2);
    $obj->brief;
    $obj->add("$l2","$l1",$l3);
    $obj->brief;
};



1;
