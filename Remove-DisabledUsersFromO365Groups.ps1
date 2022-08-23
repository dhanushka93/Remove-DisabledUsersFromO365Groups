<#
# This was used to remove use users from Cloud-Only O365 Groups.
# This was used to clean the O365 groups.

# Author: Dhanushka W
# Date: 23 Aug 2022
#>


Import-Module AzureADPreview
Import-Module AzureAD


try
{
    Write-Host "`nAlready Connected to Tenant: "(Get-AzureADCurrentSessionInfo -ErrorAction SilentlyContinue).TenantId
    
}

catch
{
    Write-Host "Connecting Azure AD .."
    Connect-AzureAD
}


Write-Host "`nGetting Disabled Users .."
$DisabledUser_OID = (Get-AzureAdUser -Top 10000| where {$_.accountenabled -eq $false}).ObjectID

foreach ($UID in $DisabledUser_OID)
{
    # When user mailbox is removed and the group is mail enabled, Remove-AzureADGroupMember cmdlet cannot remove the group members.
    #User Groups are filtered out to include only cloud groups and non-mail enabled groups.

    
    $GROUP_O365 = (Get-AzureADUserMembership -ObjectId $UID | where {($_.DirSyncEnabled -eq $null) -and ($_.MailEnabled -eq $False) }).ObjectID

    #Retrieves cloud only mail enabled groups.
    #$GROUP_MAIL_ENABLED = (Get-AzureADUserMembership -ObjectId $UID | where {($_.DirSyncEnabled -eq $null) -and ($_.MailEnabled -eq $True) }).MailNickName

    if($GROUP_O365 -ne $null)

    {
        Write-Host "`nRemoving disabled user from groups .."
        foreach($GROUP in $GROUP_O365)
        {
            AzureAD\Remove-AzureADGroupMember -MemberId $UID -ObjectId $GROUP

            $UserName = (Get-AzureADUser -ObjectId $UID ).DisplayName 
            $GroupName = (AzureADPreview\Get-AzureADGroup -ObjectId $GROUP).DisplayName
            Write-Host $UserName  " Removed from Group: "  $GroupName
        }

        
    }

}

Write-Host "`nGroup Clean-Up completed!"
