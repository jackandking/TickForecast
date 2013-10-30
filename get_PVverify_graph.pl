# Author: yingjie.liu@thomsonreuters.com
# DateTime: 2011-06-07 17:01:46

my @dbfiles=(
    # '..\poc\ricmondat\__SSEC_20110503.db',
    #'..\poc\ricmondat\__SSEC_20110504.db',
#'..\poc\ricmondat\__SSEC_20110517.db',
#'..\poc\ricmondat\__SSEC_20110518.db',
#'..\poc\ricmondat\__SSEC_20110519.db',
#'..\poc\ricmondat\__SSEC_20110520.db',
'..\data\__SSEC_20110523.db',
'..\data\__SSEC_20110524.db',
'..\data\__SSEC_20110525.db',
'..\data\__SSEC_20110526.db',
'..\data\__SSEC_20110527.db',
    
);
sub usage {
    print "$0 [interval=60] [points=3] [complete=0]\n";
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
use VerifyGraphAlgo;
use Graph2FileAlgo;

#my $dbfile = defined $ARGV[0]?$ARGV[0]:&usage;
my $interval = defined $ARGV[0]?$ARGV[0]:60;
my $points = defined $ARGV[1]?$ARGV[1]:3;
my $complete = defined $ARGV[2]?$ARGV[2]:0;
my $logger=get_logger("get_PVverify_graph");
Log::Log4perl->init("get_PVverify_graph.conf");
$logger->info("$0 [$interval] [$points] [$complete]");

my $sm=Pipe->new;
my $tm=TickModule->new;
my $bm=Pipe->new;
my $cm=Divider->new;
my $mm=MatrixModule->new;
my $fm=ForecastModule->new;
my $vm=VerifyModule->new;
my $v2gm=Pipe->new(name=>"Verify2GraphModule");
my $g2fm=Pipe->new(name=>"Graph2FileModule");

$tm->next_pipe($bm);
$bm->next_pipe($cm);
$cm->reg_pipe($mm);
$cm->reg_pipe($fm);
$mm->next_pipe($sm);
$sm->next_pipe($fm);
#$sm->next_pipe(DebugPipe->new);
$fm->next_pipe($vm);
$vm->next_pipe($v2gm);
$v2gm->next_pipe($g2fm);
$g2fm->next_pipe(DebugPipe->new);

my $ta=TickAlgo->new;
my $ba=PVBitAlgo->new;
my $ca=CodeAlgo->new;
$ca->length($points);
my $ma=Code2MatrixAlgo->new;
my $msa=MatrixStatsAlgo->new;
#my $fa=Forecast4VerifyAlgo->new;
my $fa=ForecastAlgo->new;
my $va=PVVerifyAlgo->new;
my $v2ga=VerifyGraphAlgo->new;
my $g2fa=Graph2FileAlgo->new;
$tm->algo($ta);
$bm->algo($ba);
$cm->algo($ca);
$sm->algo($sa);
$mm->algo($ma);
$sm->algo($msa);
$fm->algo($fa);
$vm->algo($va);
$v2gm->algo($v2ga);
$g2fm->algo($g2fa);

$ta->interval($interval);
$msa->interval($ta->interval);
#$fa->threshold->{effect_ratio}=0.50;
my $min_counter=10;
$fa->threshold->{counter}=$min_counter;
$fa->interval($ta->interval);


$v2gm->buffering(1);
foreach my $dbfile (@dbfiles){
    my ($table,undef,undef)=fileparse($dbfile,qr/\.[^.]*/);

    $va->dbfile($dbfile);
    $va->table($table);
    $va->open_db;

    $vm->next_pipe(DebugPipe->new);
    $tm->process_db($dbfile,"$table",-1);
    if($complete ne 0){
        foreach my $offset (1..$ta->interval-2){
            $ta->offset($offset);
            $tm->process_db($dbfile,"$table",-1);
        }
    }
    $vm->next_pipe($v2gm);
    $vm->on_recv(Flush->new);
    $mm->qmatrix->clear;
    #$va->clear;
}

#$v2gm->next_pipe(DebugPipe->new);
$g2fa->filename("scForecast2327_i${interval}_p${points}_c${min_counter}");

$v2gm->on_recv(Flush->new);
