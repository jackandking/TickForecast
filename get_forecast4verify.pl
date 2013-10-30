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
use PVBitAlgo;
use CodeAlgo;
use Code2MatrixAlgo;
use MatrixStatsAlgo;
use Forecast4VerifyAlgo;
use VerifyAlgo;
use PVVerifyAlgo;

my $dbfile = defined $ARGV[0]?$ARGV[0]:&usage;
my $interval = defined $ARGV[1]?$ARGV[1]:60;
my $points = defined $ARGV[2]?$ARGV[2]:5;
my $complete = defined $ARGV[3]?$ARGV[3]:0;
my $logger=get_logger("get_forecast4verify");
Log::Log4perl->init("get_forecast4verify.conf");
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
#$sm->next_pipe(DebugPipe->new);
$fm->next_pipe($vm);
$vm->next_pipe(DebugPipe->new);

my $ta=TickAlgo->new;
$ta->interval($interval);
my $ba=PVBitAlgo->new;
my $ca=CodeAlgo->new;
$ca->length($points);
my $ma=Code2MatrixAlgo->new;
my $msa=MatrixStatsAlgo->new;
#my $fa=Forecast4VerifyAlgo->new;
my $fa=ForecastAlgo->new;
my $va=PVVerifyAlgo->new;
$tm->algo($ta);
$bm->algo($ba);
$cm->algo($ca);
$sm->algo($sa);
$mm->algo($ma);
$sm->algo($msa);
$fm->algo($fa);
$vm->algo($va);

$msa->interval($ta->interval);
my ($table,undef,undef)=fileparse($dbfile,qr/\.[^.]*/);

$fa->threshold->{counter}=30;
    #$fa->threshold->{effect_ratio}=0.90;
    $fa->interval($ta->interval);
    $va->dbfile($dbfile);
    $va->table($table);
    $va->open_db;

$tm->process_db($dbfile,"$table",-1);
if($complete ne 0){
    foreach my $offset (1..$ta->interval-2){
        $ta->offset($offset);
        $tm->process_db($dbfile,"$table",-1);
    }
}

