use Archive::Zip qw(:ERROR_CODES);
use File::Copy();

my $zipName = shift || die 'must provide a zip name';
my $zipOut  = shift || die 'must provide a zip out name';
#my @fileNames = @ARGV;
#die 'must provide file names' unless scalar(@fileNames);
my $file = "BusinessObjects.xml";

# Read the zip
my $zip = Archive::Zip->new();
die "can't read $zipName\n" unless $zip->read($zipName) == AZ_OK;

# Update the zip
die "can't extract $file\n" unless $zip->extractMember($file) == AZ_OK;
open (IN, "+<$file");
@mfile = <IN>;
seek IN,0,0;

foreach $line(@mfile)
{
$line =~ s/bobat/bo/ig;
$line =~ s/bo_bat/bo/ig;
$line =~ s/botest/bobat/ig;
$line =~ s/bo_test/bobat/ig;
print IN $line;
}
close IN;

	$zip->removeMember($file);
	if ( -r $file )
	{
		if ( -f $file )
		{
			$zip->addFile($file) or die "Can't add $file to zip!\n";
		}
		elsif ( -d $file )
		{
			$zip->addDirectory($file) or die "Can't add $file to zip!\n";
		}
		else
		{
			warn "Don't know how to add $file\n";
		}
	}
	else
	{
		warn "Can't read $file\n";
	}


# Now the zip is updated. Write it back via a temp file.

exit( $zip->overwriteAs($zipOut) );