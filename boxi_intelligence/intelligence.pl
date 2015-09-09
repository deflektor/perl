#
use Win32::OLE qw(in with);
require "../boxi_designer/insert_into_db.pl";

my $Class = 'BusinessObjects.Application';

my $config = "settings.ini";
my $reports = "new_reports.ini";
my $user="";
my $passw="";
my $server="";
my $auth="";
my $global_report_name="";

my @reports_list;

print "$0: Exports Report Details\n";
print " Usage: perl $0 [d|c|q] [database|screen]  \n";
print "\n";
print " d|c|q can be used together, one item is required \n";
print " database|screen can be used together \n";
print " d .. DataProvider information\n";
print " c .. Columns used\n";
print " q .. Queries information\n";
print "\n";
exit if ($ARGV[1] eq "") ;

my $designer = Win32::OLE->new($Class, \&Quit) || die("cannot create a '$Class' object");
$designer->{Visible} = 1;
$designer->{Interactive}=1;

&load_settings;

$designer->Logon($user, $passw, $server, $auth, 0, 0);

$global_report_name = "BI131_Complaint_and_correction_credit_Detail";

foreach $t_report (@reports_list)
{
  next if ($t_report eq "^\s");
  
  my($rep_days)= identify_reports($t_report);
  print "\n".$t_report.": Days since ".$rep_days." Status: ";
  if ($rep_days<180 && $rep_days>0)
  {
	print "No processing";
	next;
  } elsif ($rep_days==0 || $rep_days>=180)
  {
	print "processing";
  } 
  $global_report_name=$t_report;
  print "Opening report $global_report_name last reported before $rep_days \n";
  $designer->Documents->OpenFromEnterprise($global_report_name, "Prod", 0);

  if ($ARGV[0]=~m/d/i)   # switch for "d" Dataproviders definition
  {
    &getDataproviders($designer->ActiveDocument);
  }

  $designer->ActiveDocument->Close;
}
##wait event
#$designer->Documents->OpenFromEnterpriseDialog;

undef $designer;

exit;

sub load_settings
{
  local $/=undef;
  open(CONF, "<$config") or die "$0: Cannot find '$config' file in folder\n";
  $config_in=<CONF>;
  close CONF;

  my @config_array = split(/\n/, $config_in);
  foreach $config_line (@config_array)
  {
    ($my_key, $my_value) = split (/\=/, $config_line);
    if (lc($my_key) eq "user") {$user=$my_value;}
    if (lc($my_key) eq "password") {$passw=$my_value;}
    if (lc($my_key) eq "server") {$server=$my_value;}
    if (lc($my_key) eq "authentication") {$auth=$my_value;}
    if (lc($my_key) eq "path") {$path=$my_value;}
  }

  local $/=undef;
  open(REP, "<$reports") or die "$0: Cannot find '$reports' file in folder\n";
  $reports_in=<REP>;
  close REP;

  my @reports_array = split(/\n/, $reports_in);
  foreach $rep_line (@reports_array)
  {
    next if ($rep_line =~ m/^\s/);   # remove blank lines
    next if ($rep_line =~ m/^\#/);   # remove comment lines
    push (@reports_list, $rep_line);
    #print "my reports ".scalar(@reports_list)." x".$rep_line."x\n";
  }

}


sub Quit  {
	my ($Obj) = @_;
	$Obj->Quit();
}

sub getDataproviders
{
  my $document = shift(@_);
  
  my $i_count=0;
  foreach my $datap (in $document->DataProviders) 
  {

    if ($ARGV[1]=~m/screen/i) # switch for "screen" output to database
    {
     print "Report Name                    ".$global_report_name."\n";
     print "Dataprovider Name              ".++$i_count." ".$datap->Name."\n";
     print "Dataprovider Editable          ".$i_count." ".$datap->IsEditable."\n";
     print "Dataprovider Refreshable       ".$i_count." ".$datap->IsRefreshable."\n";
     print "Dataprovider LastExecutionTime ".$i_count." ".$datap->LastExecutionTime."\n";
     print "Dataprovider MaxDuration       ".$i_count." ".$datap->MaxDuration."\n";
     print "Dataprovider MaxNbLines        ".$i_count." ".$datap->MaxNbLines."\n";
     print "Dataprovider NbCubes           ".$i_count." ".$datap->NbCubes."\n";
     print "Dataprovider NbRowsFetched     ".$i_count." ".$datap->NbRowsFetched."\n";
     print "Dataprovider PartialRefresh    ".$i_count." ".$datap->PartialRefresh."\n";
     # return link to Universe Object print "Dataprovider Universe          ".$i_count." ".$datap->Universe."\n";
     print "Dataprovider UniverseName      ".$i_count." ".$datap->UniverseName."\n";
     print "Dataprovider sql               ".$i_count." ".$datap->SQL."\n";
    }
    if ($ARGV[1]=~m/database/i) # switch for "db" output to database
    {
     sleep(10);
     &do_rep_dataprovider($global_report_name, $datap->Name, $datap->IsEditable, $datap->IsRefreshable, $datap->LastExecutionTime,
                           $datap->MaxDuration, $datap->MaxNbLines, $datap->NbCubes, $datap->NbRowsFetched, $datap->PartialRefresh,
                           $datap->UniverseName, $datap->SQL);
    }


    if ($ARGV[0]=~m/c/i)
    {
      &getColumns($datap);
    }
    if ($ARGV[0]=~m/q/i)
    {
      &getQueries($datap);
    }

  }
}

sub getColumns
{
  my $datap = shift(@_);

  my $i_count=0;
  foreach my $columns (in $datap->Columns)
  {
    if ($ARGV[1]=~m/screen/i) # switch for "screen" output to database
    {
     print $datap->Name." Columns Name         ".++$i_count." ".$columns->Name."\n";
    }
    if ($ARGV[1]=~m/database/i) # switch for "db" output to database
    {
     #&do_rep_columns($global_report_name, $columns->Name);
    }
  }
}

sub getQueries
{
  my $datap = shift(@_);

  my $i_count=0;
  
  return if (!defined $datap->Queries);

  foreach my $query (in $datap->Queries)
  {
    #if ($ARGV[1]=~m/screen/i) # switch for "screen" output to database
    {
     #print $datap->Name." Queries Name         ".++$i_count." ".$query->Name."\n";
    }
     &getResults($query, $datap->Name);
  }
}

sub getResults
{
  my $results = shift(@_);
  my $datap_name = shift(@_);

  foreach my $result (in $results->Results)
  {
    
    if ($ARGV[1]=~m/screen/i) # switch for "screen" output to database
    {
     print $global_report_name." ".$datap_name." Result Class         ".++$i_count." ".$result->Class."\n";    
     print $global_report_name." ".$datap_name." Result Object        ".$i_count." ".$result->Object."\n";    
    }
    if ($ARGV[1]=~m/database/i) # switch for "db" output to database
    {
      &do_rep_results($global_report_name, $datap_name, $result->Class, $result->Object);
    }

  }
}