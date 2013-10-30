# Author: yingjie.liu@thomsonreuters.com
# DateTime: 2011-06-19 15:40:50

#=========examples===========
# my @date = (localtime)[3,4,5];
# $date[1]++;
# $date[2]+=1900;
# my $date = join "/", @date;

#begin



package Graph2FileAlgo;
#use base qw(Exporter);
use warnings;
use strict;
use overload ('0+' => 'to_number',
				'""'=> 'as_string');
use Algorithm;

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
    $self->ext("png");
}

#sub id { $_[0]->{id}=$_[1] if defined $_[1]; $_[0]->{id} }
#sub id { $_[0]->{id}=$_[1] if @_>1; $_[0]->{id} }
sub ext { &Object::attr(@_);}
sub filename { &Object::attr(@_);}

#sub brief {
#  my $self = shift;
#  print "brief of $self:\n";
#}
sub process {
    my $self = shift;
    my ($pipe)=@_;
    $self->logger->debug("$self is processing $pipe");
    my $item=$pipe->input_queue->pop_front;
    $self->logger->debug("$self is processing $item");
    unless (defined $self->filename){
        $self->logger->error("filename is missing!");
        return undef;
    }
    my $ext=$self->ext;
    my $file=$self->filename.'.'.$self->ext;
    open(IMG, '>'.$file) or die $!;
    binmode IMG;
    print IMG $item->data->$ext;

    return Item->new(data=>"save to $file");
}
sub to_number{
	#return $_[0]->{'m_value'};
}

#sub as_string{
#	return "Graph2FileAlgo";
#}

unless(caller){
#unit test code
#set_logfile(__PACKAGE__."_ut.log");
    Log::Log4perl->init("log.conf");
	my $obj=Graph2FileAlgo->new;
	print "UT start for ".(ref $obj)."\n";
    my $gm=Pipe->new(name=>'GraphModule');
    my $fm=Pipe->new(name=>'FileModule');
    use VerifyGraphAlgo;
    my $vga=VerifyGraphAlgo->new;
    $gm->algo($vga);
    $fm->algo($obj);
    use Verify;
    my $v=Verify->new;
    $v->hit(10);
    $v->miss(9);
    $v->{table}="__SSEC_20110520";
    use DebugPipe;
    $obj->filename("ut");
    $gm->next_pipe($fm);
    $gm->on_recv($v);
};



1;
