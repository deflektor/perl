#!/usr/bin/perl
 
use Net::SSH::Perl;
 
my $host = "172.23.34.70";
my $user = "hyperion";
my $password = "password";

my %sshparam = { "port" => 1248,
		 "interactive" => "yes" } ;
#-- set up a new connection
my $ssh = Net::SSH::Perl->new($host, %sshparam);
#-- authenticate
$ssh->login($user, $pass);
#-- execute the command
my($stdout, $stderr, $exit) = $ssh->cmd("dir d:");

print $stdout."\nUnd fehler:".$stderr."\n";


####-p 1248 -l hyperion  172.23.34.70 
