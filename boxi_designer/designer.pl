#
use Win32::OLE qw(in with);
require "insert_into_db.pl";

my $Class = 'Designer.Application';

my $path="";

my $config = "designer.ini";
my $config_uni = "designer_universes.ini";
$config_uni = $ARGV[2] unless $ARGV[2] eq "";
my $config_in = "";
my $user="";
my $passw="";
my $server="";
my $auth="";

my @universe_list=undef;
my @tables=undef;
my @objects=undef;

my $global_universe_name="";


print "$0: Exports Universe Details\n";
print " Usage: perl $0 [u|t|o] [database|screen] [file with universe list] \n";
print "\n";
print " u|t|o can be used together, one item is required \n";
print " database|screen can be used together \n";
print " u .. Universe information\n";
print " t .. Tables used\n";
print " o .. Objects available\n";
print "\n";
exit if ($ARGV[1] eq "") ;

local $/=undef;
open(CONF, "<$config") or die "$0: Cannot find designer.ini file in folder\n";
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
open(CONF, "<$config_uni") or die "$0: Cannot find $config_uni file in folder\n";
$config_in=<CONF>;
close CONF;

my @config_array = split(/\n/, $config_in);
foreach $config_line (@config_array)
{
  next if ($config_line=~m/^\#/);
  push (@universe_list, $config_line);
}

$designer = Win32::OLE->new($Class, \&Quit) || die("cannot create a '$Class' object");
$designer->{Visible} = 0;
$designer->{Interactive}=0;

$designer->Logon($user, $passw, $server, $auth);

foreach $universe (@universe_list)
{
    next if ($universe eq "");
    my ($folder, $universe_name) = split(/\;/, $universe);
    print "$universe to $folder with $universe_name\n";

    $global_universe_name="";
    documentuniverse2($folder, $universe_name);
}
undef $designer;
exit;


sub Quit  {
	my ($Obj) = @_;
	$Obj->Quit();
}

sub documentuniverse2()
{
  my $m_folder = shift(@_);
  my $m_univer = shift(@_);

  $open = $designer->Universes->OpenFromEnterprise($m_folder, $m_univer) || die Win32::OLE->LastError();

  getuniverseinfo($open);
  if ($ARGV[0]=~m/t/i)   # switch for "t" tables definition
  {
    @tables=undef;
    gettables($open->Tables);
    if ($ARGV[1]=~m/database/i) # switch for "db" output to database
    {
      &do_tables(\@tables);
    }
  }
  if ($ARGV[0]=~m/o/i)  # switch for "o" object definition
  {
    @objects=undef;
    getobjectinfo($open->Classes);
    if ($ARGV[1]=~m/database/i) # switch for "db" output to database
    {
      &do_objects(\@objects);
    }
  }
  $designer->ActiveUniverse->Close();
  #$open->Close();
}

sub getuniverseinfo()
{
  my $cls = shift(@_);
  
  if ($ARGV[1]=~m/screen/i)
  {
    print "Universe Name : ".$cls->Name."\n";
    print "Universe LongName : ".$cls->LongName."\n";
    print "Universe Description : ".$cls->Description."\n";
    print "Universe Connection : ".$cls->Connection."\n";
    print "Universe Author : ".$cls->Author."\n";
    print "Universe CreationDate : ".$cls->CreationDate."\n";
    print "Universe RevisionNumber : ".$cls->RevisionNumber."\n";
    print "Universe Comments : ".$cls->Comments."\n";
    print "Universe FullName : ".$cls->FullName."\n";
  }
  &do_universe($cls->Name, $cls->LongName, $cls->Description, $cls->Connection, $cls->Author, $cls->CreationDate, $cls->RevisionNumber, $cls->Comments, $cls->FullName);
  $global_universe_name=$cls->Name;
}

sub gettables()
{
  my $cls = shift(@_);

  if ($cls->Count > 0)
  {
    for (my $citer=1; $citer<=$cls->Count; $citer++)
    {
      # to do elemente herausholen und aufrufen
      gettables2($cls->Item($citer));
    }
  }
}

sub gettables2()
{
  my $cls = shift(@_);

  my $alias_table = "";
  if ($cls->IsAlias) 
  {
    $alias_table = $cls->OriginalTable->Name();
  }

  if ($ARGV[1]=~m/screen/i)
  {
    print "Universe           : ".$global_universe_name."\n";
    print "Table Name         : ".$cls->Name."\n";
    print "Table Weight       : ".$cls->Weight."\n";
    print "Table isAlias      : ".$cls->IsAlias."\n";
    print "Table Alias for    : ".$alias_table."\n";
  }
  my @table = ($global_universe_name,$cls->Name,$cls->Weight,$cls->IsAlias,$alias_table);
  push(@tables, [@table]);

}

sub getobjectinfo
{
  my $cls = shift(@_);

  if ($cls->Count > 0)
  {
    for (my $citer=1; $citer<=$cls->Count; $citer++)
    {
      # to do elemente herausholen und aufrufen
      getclassinfo2($cls->Item($citer));
    }
  }
}

sub getclassinfo2
{
  my $cls = shift(@_);
  my $my_parent_name = shift(@_);

  if ($ARGV[1]=~m/screen/i)
  {
    print "Class Universe     : ".$global_universe_name."\n";
    print "Class Name         : ".$cls->Name."\n";
    print "Class Description  : ".$cls->Description."\n";
    print "Class Show/Hide    : ".$cls->Show."\n";
    print "Class Parent       : ".$my_parent_name."\n";
  }

  if ($cls->Classes->Count > 0)
  {
    for (my $citer=1; $citer<=$cls->Classes->Count; $citer++)
    {
      # to do elemente herausholen und aufrufen
      getclassinfo2($cls->Classes->Item($citer), $cls->Name);
    }
  }
  getobjectinfo2($cls->Objects, $cls->Name);
  
}

sub getobjectinfo2
{
  my $cls = shift(@_);
  my $my_parent_name = shift(@_);

  if ($cls->Count > 0)
  {
    for (my $oiter=1; $oiter<$cls->Count;$oiter++)
    {

      if ($ARGV[1]=~m/screen/i)
      {
        print "Object Universe    : ".$global_universe_name."\n";
        print "Object Parent      : ".$my_parent_name."\n";
        print "Object Name        : ".$cls->Item($oiter)->Name."\n";
        print "Object Description : ".$cls->Item($oiter)->Description."\n";
        print "Object Show/Hide   : ".$cls->Item($oiter)->Show."\n";
        print "Object Select      : ".$cls->Item($oiter)->Select."\n";
        print "Object Where       : ".$cls->Item($oiter)->Where."\n";
        print "Object Format      : ".$cls->Item($oiter)->Format->NumberFormat."\n";
        print "Object LOV Refresh : ".$cls->Item($oiter)->AutomaticLovRefreshBeforeUse."\n";
        print "Object LOV Export  : ".$cls->Item($oiter)->ExportLovWithUniverse."\n";
        print "Object LOV         : ".$cls->Item($oiter)->HasListofValues."\n";
        # do not enable as a refresh takes place!!!  print "Object LOV Name    : ".$cls->Item($oiter)->ListofValues->Name."\n" if ($cls->Item($oiter)->HasListofValues);
      }
      my @m_object = ($global_universe_name,$my_parent_name,$cls->Item($oiter)->Name,$cls->Item($oiter)->Description,$cls->Item($oiter)->Show,
                      $cls->Item($oiter)->Select, $cls->Item($oiter)->Where, $cls->Item($oiter)->Format->NumberFormat, $cls->Item($oiter)->AutomaticLovRefreshBeforeUse,
                      $cls->Item($oiter)->ExportLovWithUniverse, $cls->Item($oiter)->HasListofValues);
      push(@objects, [@m_object]);

    }
  }
}

