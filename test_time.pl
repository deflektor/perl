use Time::Local;
print "Difference in Seconds ".(time - timelocal(reverse(split(/[\:|\-]/,$ARGV[0]."-".$ARGV[1]))));
