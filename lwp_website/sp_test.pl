use LWP::UserAgent;
use LWP::Debug;
use SOAP::Lite on_action => sub { "$_[0]$_[1]"; };
use Authen::NTLM;# 1.09; 
import SOAP::Data 'name', 'value';

our $sp_endpoint = "https://at.three.com/sites/1140/BI/_vti_bin/Listdata.svc"; #https://at.three.com/sites/1140/BI/_vti_bin/Listdata.svc
our $sp_domain = "at.three.com";
our $sp_username = "kilicha";  ##AT-WORK\\
our $sp_password = "xxxxxxx";

#ntlmv2('sp');
ntlmv2(42);
ntlm_user($sp_username);
ntlm_host($sp_domain);
ntlm_password($sp_password);

$debug=1;

#The SOAP::Lite module needs to be told how to construct the SOAPAction header properly for Sharepoint. 
# The on_action does just this, and means you’ll end up with a SOAPAction appending the URL and the method name 
# together without anything in between (stops the default # that Sharepoint doesn’t want).
if ($debug) {
    LWP::Debug::level('+');
    SOAP::Lite->import(+trace => 'all');
}

#Use the above code to turn on debugging if you get errors.
my @ua_args = (keep_alive => 1);
my @credentials = ($sp_domain, "", $sp_username, $sp_password);
my $schema_ua = LWP::UserAgent->new(@ua_args);
delete $ENV{'https_proxy'};

sub SOAP::Transport::HTTP::Client::get_basic_credentials { return ('user' => 'password') };

$schema_ua->credentials(@credentials);
$soap = SOAP::Lite->proxy($sp_endpoint, @ua_args, credentials => \@credentials);
$soap->schema->useragent($schema_ua);
$soap->uri("http://schemas.microsoft.com/sharepoint/soap/");

#This complete mess is the necessary steps to get SOAP::Lite to use a properly configured LWP UserAgent to do NTLM authentication. SOAP::Lite uses two UserAgents, 
#one for the main SOAP calls and one for the Schema fetching. Although you don’t need to fetch a schema, I’ve included the proper set up above in case you want 
#to call $soap->service(”$sp_endpoint?WSDL”); for some reason.
$lists = $soap->GetListCollection();
#$lists=  $soap->service("$sp_endpoint");
quit(1, $lists->faultstring()) if defined $lists->fault();


#That’s all you need to do to get a list of all the lists on your Sharepoint site. And we can print them out:
my @result = $lists->dataof('//GetListCollectionResult/Lists/List');
foreach my $data (@result) {
    my $attr = $data->attr;
    foreach my $a ("Title","Description","DefaultViewUrl","Name","ID","WebId","ItemCount") 
    {
        printf "%-16s %s\n", $a, $attr->{$a};
    }
    print "\n";
}


#Or if you need to find a particular list to do operations on it, search for it in the results by looking up the Title with something like this:
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


#And here’s another useful subroutine to get all the items in a list:
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


sub hide_here_all
{
#That will use the default view. The 99999 is a hack to get all the items and stop the server “paging” the results. Putting this together you’d do something like this:
my $list_id = lists_getid('MyList');
print "List ID is: $list_id\n";
my @items = lists_getitems($list_id);
foreach my $data (@items) {
    my $attr = $data->attr;
    # print Dumper($attr);
}

#Here’s some code to add a new list item:
my $field_id = name('Field', 'New')->attr({ Name => 'ID'});
my $field_linktitle = name('Field', $title)->attr({ Name => 'Title'});
my $field_something = name('Field', $something_else)->attr({ Name => 'Something_x0020_Else'});
my $method = name('Method', [$field_id, $field_linktitle, $field_something])->attr({ ID => "anything", Cmd => 'New'});
my $batch = name('Batch', \$method);
my $in_listName = name('listName' => $list_id);
my $in_updates = name('updates' => \$batch);
my $call = $soap->UpdateListItems($in_listName, $in_updates);
quit(1, $call->faultstring()) if defined $call->fault();

#The content for Name=”ID” must be “New”. Where it says “anything” it really can be anything, it’s just an identifier for responses. You can also see that spaces are encoded as _x0020_.
my $field_id = name('Field', $sp_id)->attr({ Name => 'ID'});
my $field_something = name('Field', $something_else)->attr({ Name => 'Something_x0020_Else'});
my $method = name('Method', [$field_id, $field_appname])->attr({ ID => $jira_name, Cmd => 'Update'});
}


#http://localhost/_vti_bin/listdata.svc/Parts(3)
#https://p02.at.three.com/sites/changeportal/Lists/DemandManagement/EditForm.aspx?Title=D140017
#https://p02.at.three.com/sites/changeportal/Lists/DemandManagement/_vti_bin/listdata.svc/Parts
#https://p02.at.three.com/_vti_bin/ListData.svc
## http://myserver/_vti_bin/ListData.svc
## 	
## Typing the URL of the REST service returns a standard Atom service document that describes collections of information that are available in the SharePoint Foundation site.
## http://myserver/_vti_bin/ListData.svc/Projects
## 	
## Typing a name after the URL of the service returns SharePoint Foundation list data in XML format as a standard Atom feed that contains entries for every list item and the properties of each item, in addition to navigation properties that are represented as Atom links. Navigation properties represent relationships to other SharePoint Foundation lists that are formed through lookup columns.
## http://myserver/_vti_bin/ListData.svc/$metadata
## 	
## The SharePoint Foundation interface returns entity data model XML that describes the entity types for every list in the website.
## http://lsspf4719/sites/TestWebs/_vti_bin/listdata.svc/Employees(2)
## 	
## Returns the specified list item by ID (2) as an Atom feed with one entry that corresponds to the requested item.
## http://lsspf4719/sites/TestWebs/_vti_bin/listdata.svc/Employees?$orderby=Name
## 	
## Sorts the Atom feed by name.
## http://lsspf4719/sites/TestWebs/_vti_bin/listdata.svc/Employees?$filter=Project/Title eq 'My Project Title'
## 	
## Uses a navigation property to filter the list by title of a related project.