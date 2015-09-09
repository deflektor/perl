Add-Type -Path 'C:\Program Files\Common Files\Microsoft Shared\SharePoint Client\Microsoft.SharePoint.Client.dll'
Add-Type -Path 'C:\Program Files\Common Files\Microsoft Shared\SharePoint Client\Microsoft.SharePoint.Client.Runtime.dll'

Function Invoke-LoadMethod() {
param(
   $ClientObject = $(throw "Please provide an Client Object instance on which to invoke the generic method")
) 
   $ctx = $ClientObject.Context
   $load = [Microsoft.SharePoint.Client.ClientContext].GetMethod("Load") 
   $type = $ClientObject.GetType()
   $clientObjectLoad = $load.MakeGenericMethod($type) 
   $clientObjectLoad.Invoke($ctx,@($ClientObject,$null))
}

function CreateWikiPage()
{
param(
        [Parameter(Mandatory=$true)][string]$webUrl,
        [Parameter(Mandatory=$false)][System.Net.NetworkCredential]$credentials,
        [Parameter(Mandatory=$true)][string]$pageName,
        [Parameter(Mandatory=$true)][string]$pageContent
    )
            $templateRedirectionPageMarkup = '<%@ Page Inherits="Microsoft.SharePoint.Publishing.TemplateRedirectionPage,Microsoft.SharePoint.Publishing,Version=14.0.0.0,Culture=neutral,PublicKeyToken=71e9bce111e9429c" %> <%@ Reference VirtualPath="~TemplatePageUrl" %> <%@ Reference VirtualPath="~masterurl/custom.master" %>';
            
            $ctx = New-Object Microsoft.SharePoint.Client.ClientContext($webUrl)
            $ctx.Credentials = $credentials
            
          
            $wikiPages = $ctx.Web.Lists.GetByTitle("Pages")
            Invoke-LoadMethod -ClientObject $wikiPages
            $ctx.ExecuteQuery()
           
 
            $file = New-Object Microsoft.SharePoint.Client.FileCreationInformation
            $file.Url = $pageName
            $file.Content = [System.Text.Encoding]::UTF8.GetBytes($templateRedirectionPageMarkup)
            $file.Overwrite = $true
           
 
            $wikiFile = $wikiPages.RootFolder.Files.Add($file)
            Invoke-LoadMethod -ClientObject $wikiFile  
 
            $wikiPage = $wikiFile.ListItemAllFields
            $wikiPage["PublishingPageContent"] = $pageContent
            $wikiPage["PublishingPageLayout"] = "/_catalogs/masterpage/EnterpriseWiki.aspx, Basic Page"
            $wikiPage.Update()
            $ctx.ExecuteQuery();
 
}
 
 
$credentials = New-Object System.Net.NetworkCredential('username', 'password','domain')
$webUrl = 'https://at.three.com/sites/1140/BI/Wiki/'
$pageName = 'HK_MyFirstWikiPage.aspx'
$pageContent  = '<h1>Welcome to the Knowledge Base!</h1>'
CreateWikiPage $webUrl $credentials $pageName $pageContent