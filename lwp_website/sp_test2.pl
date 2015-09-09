use LWP::UserAgent;
use LWP::Debug;
use Data::Dumper;
use SOAP::Lite on_action => sub { "$_[0]$_[1]"; };
use Authen::NTLM qw(ntlmv2);
import SOAP::Data 'name', 'value';
our $sp_endpoint = 'https://at.three.com/sites/1140/BI/_vti_bin/Listdata.svc'; ## https://at.three.com/sites/1140/BI/_vti_bin/Listdata.svc
our $sp_domain = 'p02.at.three.com:80';
our $sp_username = 'at-work\\kilicha';
our $sp_password = 'xxxxxxxxx';


ntlmv2('sp');
$debug = 0;

if ($debug) {
    LWP::Debug::level('+');
    SOAP::Lite->import(+trace => 'all');
}

my @ua_args = (keep_alive => 1);
my @credentials = ($sp_domain, "", $sp_username, $sp_password);
my $schema_ua = LWP::UserAgent->new(@ua_args);
$schema_ua->credentials(@credentials);
$soap = SOAP::Lite->proxy($sp_endpoint, @ua_args, credentials => \@credentials);
$soap->schema->useragent($schema_ua);
$soap->uri("http://schemas.microsoft.com/sharepoint/soap/");

$lists = $soap->GetListCollection();
quit(1, $lists->faultstring()) if defined $lists->fault();

sub lists_getid
{
    my $title = shift;
    my @result = $lists->dataof('//GetListCollectionResult/Lists/List');
    foreach my $data (@result) {
        my $attr = $data->attr;
        return $attr->{ID} if ($attr->{Title} eq $title);
    }
    return undef;
}

sub lists_getitems
{
    my $listid = shift;
    my $in_listName = name('listName' => $listid);
    my $in_viewName = name('viewName' => '');
    my $in_rowLimit = name('rowLimit' => 99999);
    my $call = $soap->GetListItems($in_listName, $in_viewName, $in_rowLimit);
    quit(1, $call->faultstring()) if defined $call->fault();
    return $call->dataof('//GetListItemsResult/listitems/data/row');
}

my $list_id = lists_getid('Disk Space');
print "List ID is: $list_id\n";
my @items = lists_getitems($list_id);
foreach my $data (@items) {
    my $attr = $data->attr;
    print Dumper($attr);
}