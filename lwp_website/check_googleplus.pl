##https://plus.google.com/u/0/_/socialgraph/lookup/followers/?m=1000000
use LWP::Simple;

my $debug = 0;
my @Userarray;
open (INPUT, "<C:\\downloads\\response.txt") || die "cannot find file\n";

while (<INPUT>)
{
	#print "my Line : $_\n";
	if ($_=~m/([0-9]{21})/)
	{
		print $1."\n" if ($debug);
		push(@Userarray, $1);
	}
}
close INPUT;

my $url = "https://plus.google.com/u/0/x/about";
foreach my $user (@Userarray)
{
	print "My Users ".$user."\n" if ($debug);
	my $murl = $url;
	$murl =~ s/x/$user/;
    my $content = get($murl) or die 'Unable to get page';
	#open (OUTPUT, ">C:\\downloads\\response_out.txt");
	#print OUTPUT $content;
	#close OUTPUT;
	$content=~ m/\<title\>(.*?) - Über mich \- Google\+\<\/title\>/;
	print "User ".$1." - ";
	$content=~ m/,\[([0-9]+),\[\[\"/;
	print $1."\n";
}