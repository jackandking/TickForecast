# Author: yingjie.liu@thomsonreuters.com
# DateTime: 2011-06-07 17:01:46

sub usage {
    print "$0 <dbfile> [interval=60] [points=5] [complete=0]\n";
    exit;
}

use Log::Log4perl qw(get_logger);
use File::Basename;

use StatsModule;
use TickModule;
use BitModule;
use CodeModule;
use MatrixModule;
use ForecastModule;
use VerifyModule;
use DebugPipe;

use TickAlgo;
use BitAlgo;
use CodeAlgo;
use Code2MatrixAlgo;
use MatrixStatsAlgo;
use Forecast4VerifyAlgo;
use VerifyAlgo;

my $dbfile= defined $ARGV[0]?$ARGV[0]:&usage;
my $interval = defined $ARGV[1]?$ARGV[1]:60;
my $points = defined $ARGV[2]?$ARGV[2]:5;
my $complete = defined $ARGV[3]?$ARGV[3]:0;
my $logger=get_logger("get_best_verify");
Log::Log4perl->init("get_best_verify.conf");
$logger->info("$0 <$dbfile> [$interval] [$points] [$complete]");

my $sm=StatsModule->new;
my $tm=TickModule->new;
my $bm=BitModule->new;
my $cm=CodeModule->new;
my $mm=MatrixModule->new;
my $fm=ForecastModule->new;
my $vm=VerifyModule->new;

$tm->next_pipe($bm);
$bm->next_pipe($cm);
$cm->reg_pipe($mm);
$cm->reg_pipe($fm);
$mm->next_pipe($sm);
$sm->next_pipe($fm);
$fm->next_pipe($vm);
#$vm->next_pipe(DebugPipe->new);

my $ta=TickAlgo->new;
my $ba=BitAlgo->new;
my $ca=CodeAlgo->new;
my $ma=Code2MatrixAlgo->new;
my $msa=MatrixStatsAlgo->new;
#my $fa=Forecast4VerifyAlgo->new;
my $fa=ForecastAlgo->new;
my $va=VerifyAlgo->new;
$tm->algo($ta);
$bm->algo($ba);
$cm->algo($ca);
$sm->algo($sa);
$mm->algo($ma);
$sm->algo($msa);
$fm->algo($fa);
$vm->algo($va);

my ($table,undef,undef)=fileparse($dbfile,qr/\.[^.]*/);

$fa->threshold->{counter}=10;
#$fa->threshold->{effect_ratio}=0.90;
$va->dbfile($dbfile);
$va->table($table);
$va->open_db;
print "table:$table\tcount:".$va->nrecord."\n";

print "p\\i";
foreach my $interval (10,20,30,60,90,120){
    print "\t$interval";
}
print "\n";
foreach my $points (3..8){
    print "$points";
    foreach my $interval (10,20,30,60,90,120){
        $ca->length($points);
        $ta->interval($interval);
        $msa->interval($ta->interval);
        $fa->interval($ta->interval);

        $tm->process_db($dbfile,"$table",-1);
        if($complete ne 0){
            foreach my $offset (1..$ta->interval-2){
                $ta->offset($offset);
                $tm->process_db($dbfile,"$table",-1);
            }
        }
        print "\t".$va->hit.":".$va->miss;
        $va->clear;
    }
    print "\n";
}

