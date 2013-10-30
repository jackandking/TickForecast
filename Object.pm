# Author: yingjie.liu@thomsonreuters.com
# DateTime: 2011-05-22 22:42:25

#=========examples===========
# my @date = (localtime)[3,4,5];
# $date[1]++;
# $date[2]+=1900;
# my $date = join "/", @date;

#begin



package Object;
use base qw(Exporter);
use warnings;
use strict;
use overload ('0+' => 'to_number',
				'""'=> 'as_string');
use Log::Log4perl qw(get_logger);

my $obj_id=0;
#our @ISA = qw( base );
our @EXPORT=qw(_s);
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
	#$self->SUPER::_init();
    if(defined $self->name){
        $self->{logger}=get_logger($self->name);
    }else{
        $self->{logger}=get_logger(ref $self);
    }
    $self->logger->debug("Object<$obj_id> inited.");
    $self->{id}=$obj_id++;
}

sub id { $_[0]->{id}=$_[1] if defined $_[1]; $_[0]->{id} }
sub name { &Object::attr(@_);}
sub type { "undef" }
sub logger { $_[0]->{logger}=$_[1] if defined $_[1]; $_[0]->{logger} }
#sub t { my $attr=substr((caller(0))[3],rindex((caller(0))[3],"::")+2);$_[0]->{$attr}=$_[1] if @_>1; $_[0]->{$attr} }

#only used inside class attr
sub attr { my $attr=substr((caller(1))[3],rindex((caller(1))[3],"::")+2);$_[0]->{$attr}=$_[1] if @_>1; $_[0]->{$attr} }
sub brief {
  my $self = shift;
  $self->logger->info("brief of $self:");
  foreach my $attr (keys %$self){
      $self->logger->info("\t$attr: [".&_s($self->{$attr})."]");
  }
}

sub to_number{
	#return $_[0]->{'m_value'};
}

sub as_string{
	my $self = shift;
    if(defined $self->name){
        return (ref $self)."<".$self->name.">";
    }else{
        return (ref $self)."<".$self->id.">";
    }
    #return "Object<".$self->id.">";
}

sub _s {
    if(defined $_[0]){
        return $_[0];
    }else{
        return "undef";
    }
}

sub attri_info {
  my $self = shift;
  my $attri = shift;
  $self->logger->info("\t$attri: [".&_s($self->$attri)."]");
}

unless(caller){
#unit test code
#set_logfile(__PACKAGE__."_ut.log");
    Log::Log4perl->init("log.conf");
	my $obj=Object->new;
	print "UT start for $obj\n";
};



1;
