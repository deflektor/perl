#
# Script for extracting text from a powerpoint presentation
# Tested only on Office 2002 on Microsoft PowerPoint 10.0 Object Library

use Win32::OLE qw(in with);

my $Class = 'PowerPoint.Application';
my $File = 'X:\test.ppt';

$ppt = Win32::OLE->new($Class, \&Quit) || die("cannot create a '$Class' object");
$ppt->{Visible} = 1;
$open = $ppt->Presentations->Open($File) || die Win32::OLE->LastError(); 
 
my $Presentation = $ppt->Presentations->Item(1);
my $Slides = $Presentation->Slides();
my $SlideNum = 1;
foreach my $Slide (in $Slides) {
	print "--------------------------------------\n";
	print "Slide->Number():" . $SlideNum++ . "\n";
	print "--------------------------------------\n";

	my $Shapes = $Slide->Shapes();

	foreach my $Shape (in $Shapes) {
		my $hasTextFrame = $Shape->HasTextFrame();

		if ($hasTextFrame == -1) {
			my $TextFrame = $Shape->TextFrame();
			my $hasText = $TextFrame->HasText();

			if ($hasText == -1) {
				my $TextRange = $TextFrame->TextRange();
				my $Text = $TextRange->{Text};
				print "Text:$Text\n";
			}

		}
	}
}
sub Quit  {
	my ($Obj) = @_;
	$Obj->Quit();
}

undef $ppt;
