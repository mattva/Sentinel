$TenantID = "3fa43801-d14a-478d-8278-595a9a56df19"  #Your tenant ID
$SubscriptionID = "df73fe16-2740-447b-920a-1138d6c764b2" #Your subscription ID
$ResourceGroup = "CentralResources" #Your resource group

#If the following cmdlet produces the error 'Interactive authentication is not supported in this session,' run
#cmdlet Connect-AzAccount -UseDeviceAuthentication
#uncomment -UseDeviceAuthentication on next line
Connect-AzAccount -Tenant $TenantID #-UseDeviceAuthentication

#Select the subscription
Select-AzSubscription -SubscriptionId $SubscriptionID

#Grant access to the user at root scope "/"
$user = Get-AzADUser -SignedIn

New-AzRoleAssignment -Scope '/' -RoleDefinitionName 'Owner' -ObjectId $user.Id

#Create the auth token
$auth = Get-AzAccessToken

$AuthenticationHeader = @{
    "Content-Type" = "application/json"
    "Authorization" = "Bearer " + $auth.Token
    }

#Assign the Monitored Object Contributor role to the operator
$newguid = (New-Guid).Guid
$UserObjectID = $user.Id

$body = @"
{
            "properties": {
                "roleDefinitionId":"/providers/Microsoft.Authorization/roleDefinitions/56be40e24db14ccf93c37e44c597135b",
                "principalId": `"$UserObjectID`"
        }
}
"@

$requestURL = "https://management.azure.com/providers/microsoft.insights/providers/microsoft.authorization/roleassignments/$newguid`?api-version=2021-04-01-preview"

Invoke-RestMethod -Uri $requestURL -Headers $AuthenticationHeader -Method PUT -Body $body

##########################

#Create a monitored object
#The 'location' property value in the 'body' section should be the Azure region where the monitored object is stored. It should be the same region where you created the data collection rule. This is the region where agent communications occurs.
$Location = "NorthEurope" #Use your own location
$requestURL = "https://management.azure.com/providers/Microsoft.Insights/monitoredObjects/$TenantID`?api-version=2021-09-01-preview"
$body = @"
{
    "properties":{
        "location":`"$Location`"
    }
}
"@

$Respond = Invoke-RestMethod -Uri $requestURL -Headers $AuthenticationHeader -Method PUT -Body $body -Verbose
$RespondID = $Respond.id

##########################

#Associate a DCR to the monitored object
#See reference documentation https://learn.microsoft.com/rest/api/monitor/data-collection-rule-associations/create?tabs=HTTP
$associationName = "assoc01" #You can define your custom association name, but you must change the association name to a unique name if you want to associate multiple DCRs to a monitored object.
$DCRName = "dcr-WindowsClientOS" #Your data collection rule name

$requestURL = "https://management.azure.com$RespondId/providers/microsoft.insights/datacollectionruleassociations/$associationName`?api-version=2021-09-01-preview"
$body = @"
        {
            "properties": {
                "dataCollectionRuleId": "/subscriptions/$SubscriptionID/resourceGroups/$ResourceGroup/providers/Microsoft.Insights/dataCollectionRules/$DCRName"
            }
        }

"@

Invoke-RestMethod -Uri $requestURL -Headers $AuthenticationHeader -Method PUT -Body $body

#(Optional example) Associate another DCR to a monitored object. Remove comments around the following text to use it as a sample.
#See reference documentation https://learn.microsoft.com/en-us/rest/api/monitor/data-collection-rule-associations/create?tabs=HTTP

$associationName = "assoc02" #You must change the association name to a unique name if you want to associate multiple DCRs to a monitored object.
$DCRName = "dcr-WindowsClientOS-Security" #Your Data collection rule name

$requestURL = "https://management.azure.com$RespondId/providers/microsoft.insights/datacollectionruleassociations/$associationName`?api-version=2021-09-01-preview"
$body = @"
        {
            "properties": {
                "dataCollectionRuleId": "/subscriptions/$SubscriptionID/resourceGroups/$ResourceGroup/providers/Microsoft.Insights/dataCollectionRules/$DCRName"
            }
        }

"@

Invoke-RestMethod -Uri $requestURL -Headers $AuthenticationHeader -Method PUT -Body $body

#(Optional) Get all the associations.
$requestURL = "https://management.azure.com$RespondId/providers/microsoft.insights/datacollectionruleassociations?api-version=2021-09-01-preview"
(Invoke-RestMethod -Uri $requestURL -Headers $AuthenticationHeader -Method get).value
