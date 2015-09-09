use DBI;

$dsn="DBI:Oracle:EDWP01";
$username="admin";
$auth="xxxxxxx";


my $sql_for_sharepoint_list="select '[[BO XI Universe - '|| universe || '|' || universe ||']]' from (
select distinct universe from admin.boxi_objects order by 1 asc
)";

my $sql = "select universe, parent, name, description from admin.boxi_objects 
where show_flag=1 
order by 1 asc, 2 asc";

#&export2xml($sql);
&export2html($sql);
exit;

sub export2xml()
{
	my $a_sql= shift(@_);

        my @header_list;

	$dbh = DBI->connect($dsn, $username, $auth, \%attr);

        $sth = $dbh->prepare($a_sql);
        $sth->execute;
        # dumps file to STDOUT $sth->dump_results(4000, "\n", "|");

        for (my $i_count=0;$i_count<$sth->{NUM_OF_FIELDS}; $i_count++)
        {
           push (@header_list, $sth->{NAME}->[$i_count]);
           #print "Num of fields".$sth->{NUM_OF_FIELDS}."\n";
        }

        print "<boxi_documents>\n";
	while ( my @row = $sth->fetchrow_array)
        {
            for(my $a_count=0; $a_count<scalar(@header_list);$a_count++)
            {
               print "<$header_list[$a_count]>$row[$a_count]<\/$header_list[$a_count]>";
            }
            print "\n";
            #print "@row\n";
        }
        print "</boxi_documents>\n";
}

sub export2html()
{
	my $a_sql= shift(@_);

        my @header_list;

	$dbh = DBI->connect($dsn, $username, $auth, \%attr);

        $sth = $dbh->prepare($a_sql);
        $sth->execute;
        # dumps file to STDOUT $sth->dump_results(4000, "\n", "|");

        for (my $i_count=0;$i_count<$sth->{NUM_OF_FIELDS}; $i_count++)
        {
           push (@header_list, $sth->{NAME}->[$i_count]);
           #print "Num of fields".$sth->{NUM_OF_FIELDS}."\n";
        }

        my $s_universe,$s_object;
        print "<FONT size=3><A href="http://at.group.global/BI/BO/Project%20Wiki/BO%20XI%20-%20Universes.aspx">&lt;back</A></FONT>";
        print "<table>\n";
	while ( my @row = $sth->fetchrow_array)
        {

            if ($s_universe ne $row[0])
            {
               print "</table><table>\n";
               print "<tr><td colspan=2><h1>$header_list[0] - $row[0]</h1></td></tr>\n";
               $s_universe = $row[0];
            }

            if ($s_object ne $row[1])
            {
               print "<tr><td colspan=2><h2>Class - $row[1]</h2></td></tr>\n";
               $s_object = $row[1];
            }

            print "<tr>";
            for(my $a_count=2; $a_count<scalar(@header_list);$a_count++)
            {
               print "<td>$row[$a_count]</td>";
            }
            print "</tr>\n";
        }
        print "</table>\n";
}