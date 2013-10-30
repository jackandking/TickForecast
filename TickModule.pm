# Author: yingjie.liu@thomsonreuters.com
# DateTime: 2011-05-26 21:59:09

#=========examples===========
# my @date = (localtime)[3,4,5];
# $date[1]++;
# $date[2]+=1900;
# my $date = join "/", @date;

#begin



package TickModule;
#use base qw(Exporter);
use warnings;
use strict;
use overload ('0+' => 'to_number',
				'""'=> 'as_string');
use Pipe;
use DBI;

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

sub process_db {
	my $self = shift;
    my $db=$_[0];
    my $table=$_[1];
    my $limit=$_[2];
    unless(-e "$db"){
        $self->logger->error("$db not found!");
        return;
    }
    $self->logger->debug("processing table $table in database $db");
    my $dbh=DBI->connect("dbi:SQLite:dbname=$db","","",{RaiseError=>1,AutoCommit=>0});
    my $sql = "select * from $table limit $limit";
    $self->logger->info("sql: $sql");

    my $dbconn = $dbh->prepare($sql);
    $dbconn->execute();

    my @row_ary;
    while (@row_ary = $dbconn->fetchrow_array ){
        $self->on_recv(\@row_ary);
    }
}

#sub brief {
#  my $self = shift;
#  print "brief of $self:\n";
#}

sub to_number{
	#return $_[0]->{'m_value'};
}

#sub as_string{
#	return "TickModule";
#}

unless(caller){
#unit test code
#set_logfile(__PACKAGE__."_ut.log");
    Log::Log4perl->init("log.conf");
	my $obj=TickModule->new;
	print "UT start for ".(ref $obj)."\n";
    use TickAlgo;
    my $algo=TickAlgo->new;
    $algo->offset(10);
    $obj->algo($algo);
    $obj->next_pipe(Pipe->new);
    $obj->process_db('..\trunk\ricmondat\__SSEC_20110503.db',"__SSEC_20110503",10);
    use Tick;
    my $t1=Tick->new;
    $t1->price(1.0);
    $t1->volume(100);
    $t1->time(CORE::time);
    use Algorithm;
    $obj->algo(Algorithm->new);
    $obj->next_pipe(Pipe->new);
    my $l1=QLink->new;
    $l1->item($t1);
    $obj->on_recv($l1);
    $obj->on_recv($l1);
    $obj->on_recv($l1);
    $obj->brief;
};



1;
