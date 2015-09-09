  #!perl -w

  use SOAP::Lite;
  
  print SOAP::Lite
    ->	proxy ('http://av1w643p:8080/dswsbobje/qaawsservices/biws?WSDL=1&cuid=AQ90t9faQthBlV3sue3ED7I')
	-> GetReportBlock_Beladungsfertigstellungzeitpunkt (20)
  ;
  
  
#uri => 'http://av1w643p:8080/dswsbobje/qaawsservices/biws?WSDL=1&cuid=AQ90t9faQthBlV3sue3ED7I', 