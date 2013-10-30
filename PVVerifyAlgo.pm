# Author: yingjie.liu@thomsonreuters.com
# DateTime: 2011-06-12 13:59:08

#=========examples===========
# my @date = (localtime)[3,4,5];
# $date[1]++;
# $date[2]+=1900;
# my $date = join "/", @date;

#begin



package PVVerifyAlgo;
#use base qw(Exporter);
use warnings;
use strict;
use overload ('0+' => 'to_number',
				'""'=> 'as_string');
use Algorithm;
use Verify;
use DBI;

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
    $self->hit(0);
    $self->miss(0);
}

#sub id { $_[0]->{id}=$_[1] if defined $_[1]; $_[0]->{id} }
#sub id { $_[0]->{id}=$_[1] if @_>1; $_[0]->{id} }
sub dbfile { $_[0]->{dbfile}=$_[1] if @_>1; $_[0]->{dbfile} }
sub table { $_[0]->{table}=$_[1] if @_>1; $_[0]->{table} }
sub dbh { $_[0]->{dbh}=$_[1] if @_>1; $_[0]->{dbh} }
sub hit { $_[0]->{hit}=$_[1] if @_>1; $_[0]->{hit} }
sub miss { $_[0]->{miss}=$_[1] if @_>1; $_[0]->{miss} }

#sub brief {
#  my $self = shift;
#  print "brief of $self:\n";
#}
sub clear {
    my $self = shift;
    $self->hit(0);
    $self->miss(0);
}
sub open_db {
    my $self = shift;
    my $db=$self->dbfile;
    unless(-e "$db"){
        $self->logger->error("$db not found!");
        return;
    }
    $self->logger->debug("open database $db");
    my $dbh=DBI->connect("dbi:SQLite:dbname=$db","","",{RaiseError=>1,AutoCommit=>0});
    $self->dbh($dbh);
}
sub process {
    my $self = shift;
    #if($self->miss >0) {exit;}
    my ($pipe)=@_;
    my $forecast=$pipe->input_queue->pop_front;
    $self->logger->debug("$self is processing $forecast");
    unless (defined $self->dbh){
        $self->logger->error("db not open!");
        return undef;
    }
    unless (defined $self->table){
        $self->logger->error("table not set!");
        return undef;
    }
    if($forecast->id == Flush::id){
        $self->logger->debug("flush $self");
        my $verify=Verify->new;
        $verify->hit($self->hit);
        $verify->miss($self->miss);
        $verify->{table}=$self->table;
        return $verify;
    }
    my $db=$self->dbfile;
    my $table=$self->table;
    $self->logger->debug("processing table $table in database $db");
    my $effect_time=$forecast->cause_time + $forecast->interval;
    my $sql = "select price,volome from $table where time = $effect_time";
    $self->logger->debug("sql: $sql");

    my $dbconn = $self->dbh->prepare($sql);
    $dbconn->execute();

    my @row_ary;
    if (@row_ary = $dbconn->fetchrow_array ){
        my ($price,$volume)=@row_ary;
        $self->logger->debug("result: price=$price, volume=$volume");
        my $verify=Verify->new;
        $verify->data($forecast);
        my $price_effect=int($forecast->effect/3);
        $self->logger->debug("price effect: $price_effect");
        if($price > $forecast->cause_price and $price_effect == 1
                or $price == $forecast->cause_price and $price_effect ==0 
                or $price < $forecast->cause_price and $price_effect ==2 
        ){
            $verify->result(1);
            $self->hit($self->hit+1);
        }else{
            $verify->result(0);
            $self->miss($self->miss+1);
            #return undef;
        }
        $verify->hit($self->hit);
        $verify->miss($self->miss);
        $verify->{table}=$self->table;
        return $verify;
    }else{
        $self->logger->debug("can't verify");
        return undef;
    }
    
} 

sub to_number{
	#return $_[0]->{'m_value'};
}

#sub as_string{
#	return "VerifyAlgo";
#}

unless(caller){
#unit test code
#set_logfile(__PACKAGE__."_ut.log");
    Log::Log4perl->init("log.conf");
	my $obj=PVVerifyAlgo->new;
	print "UT start for ".(ref $obj)."\n";
};



1;
