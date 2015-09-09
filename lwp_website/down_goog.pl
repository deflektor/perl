use LWP::Simple;
#use String::Random;
#$pass = new String::Random;
#$pass->{'A'} = ['A'..'Z','a'..'z',0..9];
#print "Your password is ", $pass->randpattern("AAAAAAAA"), "\n";

my $murl = 'http://www.googleartproject.com/collection/moma-the-museum-of-modern-art/artwork/hope-ii-gustav-klimt/634004/';

my $m_result = get($murl);
my @a_result = split(/\n/, $m_result);

my (@img_result) = grep {/\<div class=\"m2.*\>/} @a_result;

print join("\n", @img_result);

open Mout, ">the_result.html";
print Mout $m_result;
close Mout;


exit;
