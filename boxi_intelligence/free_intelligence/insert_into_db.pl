use DBI;

$dsn="DBI:Oracle:EDWP01";
$username="admin";
$auth="xxxxxxx";

sub merge_to_db()
{
 my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdat) = localtime time; #print $mday.' '.($mon+1).' '.($year+1900);"


$statement = "select sysdate from dual";

# returns true or false $rv = $dbh->do($statement);
$sth = $dbh->prepare($statement);
$sth->execute;

 while ( @row = $sth->fetchrow_array ) {
    print "@row\n";
  }

}

###
sub do_rep_results()
{
	my $a_rep_name= shift(@_);
	my $a_dap_name= shift(@_);
	my $a_class= shift(@_);
	my $a_object= shift(@_);

        my $update_date = &get_time();

$dbh = DBI->connect($dsn, $username, $auth, \%attr);

my $merge_handle = $dbh->prepare('
MERGE INTO admin.boxi_query b
USING (
  SELECT ? report_name,
         ? dataprovider_name,
         ? uni_class,
         ? uni_object,
         to_date(?,\'dd.mm.yyyy\') update_date
  FROM dual) e
ON (b.report_name = e.report_name and
    b.dataprovider_name = e.dataprovider_name and
    b.uni_class = e.uni_class and
    b.uni_object = e.uni_object)
WHEN MATCHED THEN
  UPDATE SET 
         b.update_date=e.update_date
WHEN NOT MATCHED THEN
  INSERT (b.report_name,
          b.dataprovider_name,
          b.uni_class,
          b.uni_object,
          b.update_date
         )
  VALUES (e.report_name,
          e.dataprovider_name,
          e.uni_class,
          e.uni_object,
          e.update_date)
');

die "Couldn't prepare queries; aborting" unless defined $merge_handle;

my $success = 1;
   $success &&= $merge_handle->execute(
$a_rep_name,
$a_dap_name,
$a_class,
$a_object,
$update_date);

$dbh->disconnect;
}

###
sub do_rep_dataprovider()
{
	my $a_rep_name= shift(@_);
	my $a_dap_name= shift(@_);
	my $a_editable= shift(@_);
	my $a_refreshable= shift(@_);
	my $a_lastexecutiontime= shift(@_);
	my $a_maxduration= shift(@_);
	my $a_maxnblines= shift(@_);
	my $a_nbcubes= shift(@_);
     	my $a_nbrowsfetched= shift(@_);
     	my $a_partialrefresh= shift(@_);
     	my $a_universen_name= shift(@_);
     	my $a_stmt_sql= shift(@_);

        my $a_stmt_sql_1 = substr($a_stmt_sql, 0, 3999);
        my $a_stmt_sql_2 = substr($a_stmt_sql, 4000);
        my $update_date = &get_time();
  $a_dap_name="UNKOWN" unless ($a_dap_name);
$dbh = DBI->connect($dsn, $username, $auth, \%attr);

my $merge_handle = $dbh->prepare('
MERGE INTO admin.boxi_dataprovider b
USING (
  SELECT ? report_name,
         ? dataprovider_name,
         ? editable,
         ? refreshable,
         to_date(?,\'dd.mm.yyyy HH24:MI:SS\') lastexecutiontime,
         ? maxduration,
         ? maxnblines,
         ? nbcubes,
         ? nbrowsfetched,
         ? partialrefresh,
         ? universe_name,
         ? stmt_sql,
         to_date(?,\'dd.mm.yyyy\') update_date
  FROM dual) e
ON (b.report_name = e.report_name and
    b.dataprovider_name = e.dataprovider_name)
WHEN MATCHED THEN
  UPDATE SET 
         b.editable=e.editable,
         b.refreshable=e.refreshable,
         b.lastexecutiontime=e.lastexecutiontime,
         b.maxduration=e.maxduration,
         b.maxnblines=e.maxnblines,
         b.nbcubes=e.nbcubes,
         b.nbrowsfetched=e.nbrowsfetched,
         b.partialrefresh=e.partialrefresh,
         b.universe_name=e.universe_name,
         b.stmt_sql=e.stmt_sql,
         b.update_date=e.update_date
WHEN NOT MATCHED THEN
  INSERT (b.report_name,
          b.dataprovider_name,
          b.editable,
          b.refreshable,
          b.lastexecutiontime,
          b.maxduration,
          b.maxnblines,
          b.nbcubes,
          b.nbrowsfetched,
          b.partialrefresh,
          b.universe_name,
          b.stmt_sql,
          b.update_date
         )
  VALUES (e.report_name,
          e.dataprovider_name,
          e.editable,
          e.refreshable,
          e.lastexecutiontime,
          e.maxduration,
          e.maxnblines,
          e.nbcubes,
          e.nbrowsfetched,
          e.partialrefresh,
          e.universe_name,
          e.stmt_sql,
          e.update_date)
');

die "Couldn't prepare queries; aborting" unless defined $merge_handle;

my $success = 1;
   $success &&= $merge_handle->execute(
$a_rep_name,
$a_dap_name,
$a_editable,
$a_refreshable,
$a_lastexecutiontime,
$a_maxduration,
$a_maxnblines,
$a_nbcubes,
$a_nbrowsfetched,
$a_partialrefresh,
$a_universen_name,
$a_stmt_sql_1,
$update_date);

$dbh->disconnect;
}


###
sub do_universe()
{
	my $a_name= shift(@_);
	my $a_longname= shift(@_);
	my $a_description= shift(@_);
	my $a_connection= shift(@_);
	my $a_author= shift(@_);
	my $a_creation= shift(@_);
	my $a_revision= shift(@_);
	my $a_comments= shift(@_);
     	my $a_fullname= shift(@_);

        if (length($a_creation)<10)
        {
            print "changing creation Date from $a_creation to ";
            $a_creation = "0".$a_creation;
            print $a_creation."!\n";
        }
        $a_comments = substr($a_comments, 0, 1000);

        my $update_date = &get_time();

$dbh = DBI->connect($dsn, $username, $auth, \%attr);

my $merge_handle = $dbh->prepare('
MERGE INTO admin.boxi_universe b
USING (
  SELECT ? name,
         ? longname,
         ? description,
         ? connection,
         ? author,
         to_date(?,\'dd.mm.yyyy\') creation_date,
         ? revision,
         ? comments,
         ? fullname,
         to_date(?,\'dd.mm.yyyy\') update_date
  FROM dual) e
ON (b.name = e.name)
WHEN MATCHED THEN
  UPDATE SET b.longname=e.longname,
         b.description=e.description,
         b.connection=e.connection,
         b.author=e.author,
         b.creation_date=e.creation_date,
         b.revision=e.revision,
         b.comments=e.comments,
         b.fullname=e.fullname,
         b.update_date=e.update_date
WHEN NOT MATCHED THEN
  INSERT (b.name,
          b.longname,
          b.description,
          b.connection,
          b.author,
          b.creation_date,
          b.revision,
          b.comments,
          b.fullname,
          b.update_date
         )
  VALUES (e.name,
          e.longname,
          e.description,
          e.connection,
          e.author,
          e.creation_date,
          e.revision,
          e.comments,
          e.fullname,
          e.update_date)
');

die "Couldn't prepare queries; aborting" unless defined $merge_handle;

my $success = 1;
   $success &&= $merge_handle->execute(
$a_name,
$a_longname,
$a_description,
$a_connection,
$a_author,
$a_creation,
$a_revision,
$a_comments,
$a_fullname,
$update_date);

$dbh->disconnect;
}

sub do_tables()
{
  my $sub_tables = shift;
  $dbh = DBI->connect($dsn, $username, $auth, \%attr);

  my $update_date = &get_time();

  my $merge_handle = $dbh->prepare('
   MERGE INTO admin.boxi_tables b
   USING (
    SELECT ? universe,
         ? name,
         ? weight,
         ? alias_flag,
         ? alias_table,
         to_date(?,\'dd.mm.yyyy\') update_date
    FROM dual) e
   ON (b.universe=e.universe and b.name = e.name)
   WHEN MATCHED THEN
   UPDATE SET b.weight=e.weight,
         b.alias_flag=e.alias_flag,
         b.alias_table=e.alias_table,
         b.update_date=e.update_date
   WHEN NOT MATCHED THEN
    INSERT (b.universe,
          b.name,
          b.weight,
          b.alias_flag,
          b.alias_table,
          b.update_date
         )
    VALUES (e.universe,
          e.name,
          e.weight,
          e.alias_flag,
          e.alias_table,
          e.update_date)
  ');

  die "Couldn't prepare queries; aborting" unless defined $merge_handle;

  for $m_table (@$sub_tables)
  {
    next if (@$m_table[0] eq "");
    #my $alias_table = "";
    #$alias_table = @$m_table[4] unless (@$m_table[4] eq "");
    $merge_handle->execute(@$m_table[0], @$m_table[1], @$m_table[2], @$m_table[3], @$m_table[4], $update_date );
  }

  $dbh->disconnect;
}

sub do_objects()
{
  my $sub_objects = shift;
  $dbh = DBI->connect($dsn, $username, $auth, \%attr);

  my $update_date = &get_time();

  my $merge_handle = $dbh->prepare('
   MERGE INTO admin.boxi_objects b
   USING (
    SELECT ? universe,
         ? parent,
         ? name,
         ? description,
         ? show_flag,
         ? stmt_select,
         ? stmt_where,
         ? stmt_format,
         ? lov_refresh_flag,
         ? lov_export_flag,
         ? lov_flag,
         to_date(?,\'dd.mm.yyyy\') update_date
    FROM dual) e
   ON (b.universe=e.universe and b.parent=e.parent and b.name = e.name)
   WHEN MATCHED THEN
   UPDATE SET b.description=e.description,
         b.show_flag=e.show_flag,
         b.stmt_select=e.stmt_select,
         b.stmt_where=e.stmt_where,
         b.stmt_format=e.stmt_format,
         b.lov_refresh_flag=e.lov_refresh_flag,
         b.lov_export_flag=e.lov_export_flag,
         b.lov_flag=e.lov_flag,
         b.update_date=e.update_date
   WHEN NOT MATCHED THEN
    INSERT (b.universe,
          b.parent,
          b.name,
          b.description,
          b.show_flag,
          b.stmt_select,
          b.stmt_where,
          b.stmt_format,
          b.lov_refresh_flag,
          b.lov_export_flag,
          b.lov_flag,
          b.update_date
         )
    VALUES (e.universe,
          e.parent,
          e.name,
          e.description,
          e.show_flag,
          e.stmt_select,
          e.stmt_where,
          e.stmt_format,
          e.lov_refresh_flag,
          e.lov_export_flag,
          e.lov_flag,
          e.update_date)
  ');

  die "Couldn't prepare queries; aborting" unless defined $merge_handle;

  for $m_objects (@$sub_objects)
  {
    next if (@$m_objects[0] eq "");
    #my $alias_table = "";
    #$alias_table = @$m_table[4] unless (@$m_table[4] eq "");
    $merge_handle->execute(@$m_objects[0], @$m_objects[1], @$m_objects[2], @$m_objects[3], 
                   @$m_objects[4], @$m_objects[5], @$m_objects[6], @$m_objects[7], 
                   @$m_objects[8], @$m_objects[9], @$m_objects[10], $update_date );
  }

  $dbh->disconnect;
}

sub get_time()
{
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdat) = localtime time;
  if ($mday < 10)
  {
    $mday = "0".$mday;
  }
  return "".$mday.".".($mon+1).".".($year+1900);
}

1;
