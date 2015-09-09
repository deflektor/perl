use Win32::OLE;

#$user=Win32::OLE->GetObject("LDAP://CN=Hakan Kilic,CN=Users,DC=at-work,DC=local");
$user=Win32::OLE->GetObject("LDAP://CN=APBO.FMSRA.Producer,OU=FMSRA,OU=BusinessObjects,OU=ApplicationRoles,OU=OrganizationalGroups_Roles,OU=2Groups,OU=Hutchison3G Austria,DC=at-work,DC=local");    

print $user->{'member'}, "\n";
