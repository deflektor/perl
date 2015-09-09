use SOAP::Lite;

print "Connecting to Job Prrocessing Service ...\n";

$soap = SOAP::Lite
	-> service('http://av1w643p:8080/dswsbobje/qaawsservices/biws?WSDL=1&cuid=AQ90t9faQthBlV3sue3ED7I')
;
my $w_service = $soap
	->
	#-> GetReportBlock_Beladungsfertigstellungzeitpunkt (login=>'administrator', password=>'BoxiProd');

	@res = $soap_response->paramsout;
	
	$res = $soap_response->result;
	print "Result is $res, outparams are @res\n";
	