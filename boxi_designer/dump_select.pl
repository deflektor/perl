use DBI;
use DBIx::Dump;

$dsn="DBI:Oracle:EDWP04";
$username="admin";
$auth="xxxxxxxx";

open(CONF, "<$ARGV[1]") or die "$0: Cannot find $ARGV[1] file in folder\n";
$config_in=<CONF>;
close CONF;
#my @config_array = split(/\n/, $config_in);


my $dbh = DBI->connect($dsn, $username, $auth, {PrintError => 0, RaiseError => 1});
my $sth = $dbh->prepare($config_in);
$sth->execute();

my $exceldb = DBIx::Dump->new('format' => 'csv', 'ouput' => 'db.csv', 'sth' => $sth, EventHandler => \@handler);
$exceldb->dump();
$dbh->disconnect;
exit;