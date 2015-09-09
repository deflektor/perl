use Net::SSH::Perl;
$host="213.94.78.164";
$user="webiadm";
$pass="em.udbd";
$cmd="tail -1 /appl/apache/tomcat/logs/catalina.out";
my $ssh = Net::SSH::Perl->new($host);
$ssh->login($user, $pass);
my($stdout, $stderr, $exit) = $ssh->cmd($cmd);
if ($stdout eq "Stopping service Tomcat-Apache")
{
	print "Fehler in Tomcat";
}
exit;