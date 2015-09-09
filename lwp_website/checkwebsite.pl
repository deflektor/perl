use LWP::Simple qw($ua head);
use String::Random;
$pass = new String::Random;
$pass->{'A'} = ['A'..'Z','a'..'z',0..9];
  #print "Your password is ", $pass->randpattern("AAAAAAAA"), "\n";

$ua->timeout(10);  

my $murl = 'http://www.die-umfrage.at/form/ARGO-kulturkompass/';
while (1)
{  

#my $url = 'http://www.die-umfrage.at/form/ARGO-kulturkompass/8XAxt243';
#my $url = 'http://www.die-umfrage.at/form/ARGO-kulturkompass/E6iCN67c';

my $url = $murl.$pass->randpattern("AAAAAAAA");
if (head($url)) {
  print "Does exist $url\n";
  exit;
} else {
  print "Does not exist or timeout\n";;
}
}
exit;
