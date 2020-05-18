<#

#Requires -Module Az.Accounts,Az.Resources
#Requires - Module ImportExcel
#Install-Module ImportExcel

Script by:Kyle Green
Email: kgreen@consult-prodigy.com

####Purpose####
The purpose of this script is to export all Azure IAM permissions from each subscription and highlight any entries that are explicit permissions or owner-level permissions

            #Login to your Azure Organzaiton using an administrator account using login-azaccount before running script
            #Make sure ImportExcel has been installed
            #Edit the "excel_path" variable for output location
            #Run the run-azpermissions command

#>


#Path for the report
$Timestamp = get-date -f yyyy-MM-dd-hh-mm
$excel_path = "c:\scripts\AzurePermissionsExport_"+$timestamp+".xlsx"

$Subscriptions = Get-AzSubscription | Where {$_.name -notlike "Access to Azure Active Directory"}


$final = @()

Foreach ($sub in $Subscriptions) {

    Write-Host "Changing to Subscription to" $sub.name -ForegroundColor Yellow

    Select-AzSubscription -subscription $sub.id 

    
    Write-Host "Getting Subscription-level Permissions" -ForegroundColor Yellow

    $perms = Get-AzRoleAssignment -scope ("/subscriptions/"+$sub.id) | Select RoleDefinitionName,DisplayName,SignInName,ObjectType,Scope, 
             @{name='SecurityMessage';expression = {"$null"}},@{name='TenantId';expression = {$sub.TenantId}},@{name='SubscriptionName';expression = {$sub.Name}}

        foreach ($p in $perms) {

        if (($p.SignInName -ne $Null) -and ($p.RoleDefinitionName -like "Owner")) {

            $p.SecurityMessage = "Explicit Permission, Owner Permissions"
            $final += $p
        }
        elseif (($p.SignInName -ne $null) -and ($p.RoleDefinitionName -notlike "Owner")) {
            
            $p.SecurityMessage = "Explicit Permission"
            $final += $p
        }
        elseif ($p.RoleDefinitionName -like "Owner") {
            $p.SecurityMessage = "Owner Permission"
            $final += $p
        }
        else {

        $final += $p
        
        }
        
      }
    }


 $final | Export-Excel -Path $excel_path -ConditionalText $(
 New-ConditionalText "Explicit Permission" Black Red
 New-ConditionalText "Owner Permission" Black Orange
 ) -FreezeTopRow -BoldTopRow
