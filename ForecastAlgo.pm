# Author: yingjie.liu@thomsonreuters.com
# DateTime: 2011-06-11 18:32:42

#=========examples===========
# my @date = (localtime)[3,4,5];
# $date[1]++;
# $date[2]+=1900;
# my $date = join "/", @date;

#begin



package ForecastAlgo;
#use base qw(Exporter);
use warnings;
use strict;
use overload ('0+' => 'to_number',
				'""'=> 'as_string');
use Algorithm;
use Forecast;

our @ISA = qw(Algorithm);
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
    $self->{threshold}={};
}

#sub id { $_[0]->{id}=$_[1] if defined $_[1]; $_[0]->{id} }
#sub id { $_[0]->{id}=$_[1] if @_>1; $_[0]->{id} }
sub qmatrix { $_[0]->{qmatrix}=$_[1] if @_>1; $_[0]->{qmatrix} }
sub stats { $_[0]->{stats}=$_[1] if @_>1; $_[0]->{stats} }
sub threshold { $_[0]->{threshold}=$_[1] if @_>1; $_[0]->{threshold} }
sub interval { $_[0]->{interval}=$_[1] if @_>1; $_[0]->{interval} }
#sub brief {
#  my $self = shift;
#  print "brief of $self:\n";
#}

sub process {
    my $self = shift;
    my ($pipe)=@_;
    my $obj=$pipe->input_queue->pop_front;
    $self->logger->debug("$self is processing $obj");
    if(ref $obj eq "Stats"){
        $self->stats($obj);
        $self->qmatrix($obj->data->qmatrix);
        return undef;
    }
    if(ref $obj eq "Code"){
        my $code=$obj;
        $code->queue->pop_front;#get subcode
        $code->calc_base_value;
        $self->logger->debug("$self is actually processing $code");
        if(defined $self->qmatrix){
            #$self->qmatrix->brief;
            #$code->brief;
            my $map=$self->qmatrix->matrix->{$code->base_value};
            unless(defined $map){
                $self->logger->debug("can't forecast for $code");
                return undef ;
            }
            my $sum=0;
            foreach my $key (keys %$map){
                $sum+=$map->{$key}->count;
            }
            my $str="";
            my $effect;
            my $effect_ratio;
            foreach my $key (sort {$map->{$b}->count <=> $map->{$a}->count} keys %$map){
                unless (defined $effect){
                    $effect=$key;
                    $effect_ratio=$map->{$key}->count;
                }
                $str.="$key: ".sprintf("%.2f",$map->{$key}->count*100/$sum)."\t";
            }
            #$self->logger->debug("content: $str");
            if($str ne ""){
                my $forecast=Forecast->new;
                $forecast->cause($code->base_value);
                $forecast->cause_time($code->t_time);
                $forecast->cause_price($code->queue->tail->item->queue->tail->item->price);
                $forecast->effect($effect);
                $forecast->effect_ratio($effect_ratio/$sum);
                $forecast->content($str);
                $forecast->interval($self->interval);
                if(defined $self->stats){
                    $forecast->counter($self->stats->counter->{$code->base_value});
                    $forecast->time_sd($self->stats->time_sd->{$code->base_value});
                    $forecast->time_sep($self->stats->time_sep->{$code->base_value});
                }
                #foreach my $attr ("counter","time_sd","time_sep","effect_ratio"){
                foreach my $attr ((keys %{$self->stats}),(keys %$forecast)){
                    if(defined $self->threshold->{$attr}){
                        if($forecast->$attr < $self->threshold->{$attr}){
                            $self->logger->debug("can't forecast due to threshold of $attr");
                            return undef;
                        }
                    }
                }
                return $forecast;
            }else{
                $self->logger->debug("forecast fail!");
                return undef;
            }
        }else{
            $self->logger->warn("matrix not set!");
            return undef;
        }
    }
    $self->logger->error("unexpected input type: ".(ref $obj));
    return undef;
}

sub to_number{
	#return $_[0]->{'m_value'};
}

#sub as_string{
#	return "ForecastAlgo";
#}

unless(caller){
#unit test code
#set_logfile(__PACKAGE__."_ut.log");
    Log::Log4perl->init("log.conf");
	my $obj=ForecastAlgo->new;
	print "UT start for ".(ref $obj)."\n";
};



1;
