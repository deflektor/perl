use feature ':5.10';
use DBI;

#globla settings
$dsn="DBI:Oracle:".$ARGV[2];
$username=uc($ARGV[0]);
$auth=$ARGV[1];

print "Usage $0 \n user password TNS outputpath \n";
print "Example: edw passedw EDWD02 C:/ST/DI \n";

$start_path = $ARGV[3];
#global vars
my @working_array;
my $dbh;
my $last_object_type;
#runtime
&my_connect;
&connect_db;


foreach $row (0..@working_array)
{
	next if (@{$working_array[$row]}[2] eq "");
	if (@{$working_array[$row]}[1]eq "DATABASE LINK")
	{
		#say "Hello found a database link";
		&get_databaselink(@{$working_array[$row]});
	} else
	{
			if (@{$working_array[$row]}[1] eq "PACKAGE" & $last_object_type ne "PACKAGE")
			{
				&set_transform_spec;
			} elsif (@{$working_array[$row]}[1] eq "PACKAGE BODY" &&  $last_object_type ne "PACKAGE BODY")
			{
				&set_transform_body;
			} elsif (@{$working_array[$row]}[1] ne "PACKAGE BODY"   &&
					  @{$working_array[$row]}[1] ne "PACKAGE"       &&
					  ($last_object_type eq "PACKAGE BODY"            ||
					   $last_object_type eq "PACKAGE"
					  )
					)
			{
				&set_transform_reset;
			}
		&get_metadata(@{$working_array[$row]});
		if (@{$working_array[$row]}[1] eq "TABLE" || @{$working_array[$row]}[1] eq "TRIGGER")
		{
			my $in_filename = $start_path."/".@{$working_array[$row]}[0]."/".uc(@{$working_array[$row]}[2]).".".lc(@{$working_array[$row]}[1]).".sql";
			my $out_filename = $start_path."/".@{$working_array[$row]}[0]."/".uc(@{$working_array[$row]}[2]).".".lc(@{$working_array[$row]}[1]).".new.sql";
			my $out_filename_part = $start_path."/".@{$working_array[$row]}[0]."/".uc(@{$working_array[$row]}[2]).".".lc(@{$working_array[$row]}[1]).".constraint.sql";
                        #say "Opening files : $in_filename \n";
			open (INPUTFILE, "<$in_filename");
			my $in_string = do { local $/; <INPUTFILE> };
			close INPUTFILE;
			my @input_string_array = split (";", $in_string);
			open (OUTPUTFILE, ">$in_filename") || die "$!: cannot open file $in_filename\n";
			print OUTPUTFILE shift(@input_string_array).";";
			close OUTPUTFILE;
			open (OUTPUTFILE, ">$out_filename_part");
			print OUTPUTFILE join(";", @input_string_array).";";
			close OUTPUTFILE;
		}
		&get_metadata_dependant(@{$working_array[$row]});
	}
	
	$last_object_type = @{$working_array[$row]}[1];
	#foreach $column (0..@{$working_array[$row]})
	#{
    #		print "Element [$row][$column] = ".$working_array[$row][$column]." \n";
	#}
}
&disconnect_db;
exit;

sub connect_db()
{
	$dbh = DBI->connect($dsn, $username, $auth, \%attr);
	$dbh->{LongReadLen} = 10000000;
	$dbh->{mysql_auto_reconnect} = 1;
	
	$dbh->do("
	BEGIN
		DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'PRETTY',TRUE);
		DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SIZE_BYTE_KEYWORD',TRUE);
		DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SQLTERMINATOR',TRUE);
		DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'STORAGE',FALSE);
		DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SEGMENT_ATTRIBUTES',TRUE);
		DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'TABLESPACE',TRUE);
		DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'CONSTRAINTS',TRUE);
		DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'REF_CONSTRAINTS',TRUE);
		DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'CONSTRAINTS_AS_ALTER',TRUE);
		DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'OID',FALSE);
		DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SPECIFICATION',TRUE);
		DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'BODY',TRUE);
		DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'FORCE',FALSE);
		DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'INSERT',FALSE);
	END;	
	");
}

sub set_transform_body()
{
	$dbh->do("
	BEGIN
		DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SPECIFICATION',FALSE);
		DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'BODY',TRUE);
	END;	
	");
}

sub set_transform_spec()
{
	$dbh->do("
	BEGIN
		DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SPECIFICATION',TRUE);
		DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'BODY',FALSE);
	END;	
	");
}

sub set_transform_reset()
{
	$dbh->do("
	BEGIN
		DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SPECIFICATION',TRUE);
		DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'BODY',TRUE);
	END;	
	");
}

sub disconnect_db()
{
	$dbh->disconnect;
}

#functions
sub my_connect()
{
	$dbh = DBI->connect($dsn, $username, $auth, \%attr);

	my $merge_handle = $dbh->prepare("
			select owner, 
                   case when(object_type='PACKAGE') then 'PACKAGE_SPEC'
                        when(object_type='PACKAGE BODY') then 'PACKAGE_BODY'
                        else object_type
                   end object_type, object_name, max(subobject_name), max(last_ddl_time) from dba_objects
			where 1=1
			and 
			(
				   object_type in ('DATABASE LINK','DIMENSION','INDEX PARTITION', 'INDEX SUBPARTITION','JOB','PROCEDURE','PROGRAM','SCHEDULE','SCHEDULER GROUP','SEQUENCE')
				or object_type in ('SEQUENCE','PROCEDURE','PACKAGE','PACKAGE BODY','MATERIALIZED VIEW','TABLE','INDEX','FUNCTION','VIEW', 'SYNONYM') 
				or object_type in ('TRIGGER','TYPE', 'TYPE BODY','WINDOW')
			)
			and object_name not like 'X_%'
			and object_name not like 'SYS_%'
      and owner ='$username'
			and status = 'VALID'
			group by owner, object_type, object_name
			order by 1 asc, 2 asc, 3 asc, 4 asc, 5 asc
	");

	#--'TYPE','TRIGGER','INDEX SUBPARTITION','LOB','TYPE BODY','INDEX PARTITION','TABLE PARTITION',

	die "Couldn't prepare queries; aborting" unless defined $merge_handle;

	$merge_handle->execute();

	my ($owner, $object_type, $object_name, $subobject_name, $last_ddl_time);
	$merge_handle->bind_col(1, \$owner);
	$merge_handle->bind_col(2, \$object_type);
	$merge_handle->bind_col(3, \$object_name);
	$merge_handle->bind_col(4, \$subobject_name);
	$merge_handle->bind_col(5, \$last_ddl_time);

	while ($merge_handle->fetch)
	{
		#print "$owner, $object_type, $object_name, $subobject_name, $last_ddl_time\n";
		#next if ($object_name eq " ");
		push(@working_array, [($owner, $object_type, $object_name, $subobject_name, $last_ddl_time)]);
	}

	$dbh->disconnect;
}

sub get_databaselink()
{
	my ($owner, $object_type, $object_name, $subobject_name, $last_ddl_time) = @_;
	
	#$object_type =~ s/\s/\_/g;
	print $object_type." ".$owner." ".$object_name."\n";
	
	my $sql_exec = $dbh->prepare("SELECT 'CREATE DATABASE LINK ' || owner ||'.' || db_link || ' CONNECT TO ' || username || ' IDENTIFIED BY <PWD>' || ' USING ''' || HOST || ''';' FROM dba_db_links where owner='".$owner."' and db_link='".$object_name."'");
	
	my $return_col;
	$sql_exec->bind_col(1, \$return_col);
	$sql_exec->execute;
	
	while ($sql_exec->fetch)
	{
		my $out_filename;
		my $out_string = $return_col;
		$out_string =~ s/\"((\w|\d)*?)\"/$1/g;
		$object_type =~ s/\s/\_/g;
		given ($object_type) {
		 when ("anyvalue")
		 {
			$out_filename = $start_path."/$owner/xxx/".$object_name.".sql";
		 }
		 default       
		 {
			$out_filename = $start_path."/$owner/".uc($object_name).".".lc($object_type).".sql";
		 }
		}
		
		open(OUT_STD, ">$out_filename")|| die "Cannot create file $!\n";
		print OUT_STD $out_string;
		close OUT_STD;
		
		$sql_exec->finish;
	}
	#select DBMS_METADATA.GET_GRANTED_DDL('SYSTEM_GRANT','EDW') from dual;
	#select DBMS_METADATA.GET_DEPENDENT_DDL('OBJECT_GRANT','V_ACCOUNT','EDW') from dual;
}


sub get_metadata()
{
	my ($owner, $object_type, $object_name, $subobject_name, $last_ddl_time) = @_;
    
	#$object_type =~ s/\s/\_/g;
	print $object_type." ".$owner." ".$object_name."\n";
	
	my $sql_exec = $dbh->prepare("select DBMS_METADATA.GET_DDL('".$object_type."', '".$object_name."', '".$owner."') from dual");
	
	my $return_col;
	$sql_exec->bind_col(1, \$return_col);
	$sql_exec->execute;
	
	while ($sql_exec->fetch)
	{
		my $out_filename;
		my $out_string = $return_col;
		$out_string =~ s/\"((\w|\d)*?)\"/$1/g;
		$out_string =~ s/^(\n|\r)+\s+//g;
		#$out_string =~ s/ PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255\s*(\n\r)*//g;
		#$out_string =~ s/ PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS\s*(\n\r)*//g;
		#$out_string =~ s/ PCTFREE 10 INITRANS 2 MAXTRANS 255\s*(\n\r)*//g;
		#$out_string =~ s/ PCTFREE 10 PCTUSED 0 INITRANS 1 MAXTRANS 255\s*(\n\r)*//g;
		$out_string =~ s/ COMPUTE STATISTICS\s*(\n\r)*//g;
		$out_string =~ s/START WITH (\d+)/START WITH 1/ if ($object_type eq "SEQUENCE");
		#$out_string =~ s/\n\n+/\n/g;
		#$out_string =~ s/\n  TABLESPACE/ TABLESPACE/g;
		$object_type =~ s/\s/\_/g;
		given ($object_type) {
		 when ("anyvalue")
		 {
			$out_filename = $start_path."/$owner/xxx/".$object_name.".sql";
		 }
		 default       
		 {
			$out_filename = $start_path."/$owner/".uc($object_name).".".lc($object_type).".sql";
		 }
		}
		
		open(OUT_STD, ">$out_filename")|| die "Cannot create file $out_filename : $!\n";
		print OUT_STD $out_string;
		close OUT_STD;
		
		# creates errors, maybe not necessary
		##$sql_exec->finish;
	}
	#select DBMS_METADATA.GET_GRANTED_DDL('SYSTEM_GRANT','EDW') from dual;
	#select DBMS_METADATA.GET_DEPENDENT_DDL('OBJECT_GRANT','V_ACCOUNT','EDW') from dual;
}

sub get_metadata_dependant()
{
	my ($owner, $object_type, $object_name, $subobject_name, $last_ddl_time) = @_;
	
	$object_type =~ s/\s/\_/g;
	#print $object_type." ".$owner." ".$object_name."\n";
	
	my $sql_exec = $dbh->prepare("select DBMS_METADATA.GET_DEPENDENT_DDL('OBJECT_GRANT','".$object_name."','".$owner."') from dual");
		
	my $return_col;
	
	$sql_exec->execute
		or die "Couldn't execute statement: " . $sql_exec->errstr;
	
	$sql_exec->bind_col(1, \$return_col);
	
	while ($sql_exec->fetch && $sql_exec > 0)
	{
		my $out_filename;
		my $out_string = $return_col;
		$out_string =~ s/\"((\w|\d)*?)\"/$1/g;
		
		given ($object_type) {
		 default       
		 {
			$out_filename = $start_path."/$owner/".uc($object_name).".".lc($object_type).".grant.sql";
		 }
		}
		
		open(OUT_STD, ">$out_filename")|| die "Cannot create file $!\n";
		print OUT_STD $out_string;
		close OUT_STD;
	}

	$sql_exec->finish;
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

