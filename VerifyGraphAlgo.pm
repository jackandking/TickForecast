# Author: yingjie.liu@thomsonreuters.com
# DateTime: 2011-06-18 22:01:38

#=========examples===========
# my @date = (localtime)[3,4,5];
# $date[1]++;
# $date[2]+=1900;
# my $date = join "/", @date;

#begin



package VerifyGraphAlgo;
#use base qw(Exporter);
use warnings;
use strict;
use overload ('0+' => 'to_number',
				'""'=> 'as_string');
use Algorithm;
use GD::Graph::bars;
use Item;

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
    my $my_graph =GD::Graph::bars->new;
    $my_graph->set( 
        x_label => 'date', 
        y_label => 'hit/miss', 
        title => 'forecast hit/miss', 
        #long_ticks => 1, 
        #y_max_value => 40, 
        #y_tick_number => 8, 
        #y_label_skip => 2, 
        #bar_spacing => 3, 
        #shadow_depth => 4, 

        #accent_treshold => 200, 

        transparent => 0, 
    ); 

    $my_graph->set_legend('hit', 'miss'); 
    $self->graph($my_graph);
}

#sub id { $_[0]->{id}=$_[1] if defined $_[1]; $_[0]->{id} }
#sub id { $_[0]->{id}=$_[1] if @_>1; $_[0]->{id} }
sub graph { &Object::attr(@_);}

#sub brief {
#  my $self = shift;
#  print "brief of $self:\n";
#}

sub process {
    my $self = shift;
    #if($self->miss >0) {exit;}
    my ($pipe)=@_;
    my $verify=$pipe->input_queue->pop_front;

    my @table;
    my @dates;
    my @hit;
    my @miss;
    while(defined $verify){
        if($verify->id == Flush::id){
            $self->logger->debug("ignore Flush.");
            $verify=$pipe->input_queue->pop_front;
            next;
        }
        $self->logger->debug("$self is processing $verify");
        @table=split /_/,$verify->{table};
        my $date=$table[$#table];
        push @dates,$date; 
        push @hit,$verify->hit; 
        push @miss,$verify->miss; 
        $verify=$pipe->input_queue->pop_front;
    }
    return undef unless @dates >0;
    my $ric=join ".",@table[1..$#table-1];
    $self->graph->set( title => "Forecast for $ric", );
    $self->logger->debug("plot");
    my @data=([@dates],[@hit],[@miss]);
    my $gd=$self->graph->plot(\@data); 
    my $item=Item->new;
    $item->data($gd);
    return $item;
}
sub to_number{
	#return $_[0]->{'m_value'};
}

#sub as_string{
#	return "VerifyGraphAlgo";
#}

unless(caller){
#unit test code
#set_logfile(__PACKAGE__."_ut.log");
    Log::Log4perl->init("log.conf");
	my $obj=VerifyGraphAlgo->new;
	print "UT start for ".(ref $obj)."\n";
    my $m=Pipe->new;
    $m->algo($obj);
    use Verify;
    my $v=Verify->new;
    $v->hit(10);
    $v->miss(9);
    $v->{table}="__SSEC_20110520";
    use DebugPipe;
    $m->next_pipe(DebugPipe->new);
    $m->on_recv($v);

    #open(IMG, '>file.png') or die $!;
    #binmode IMG;
    #print IMG $gd->png;
    
    
};



1;
