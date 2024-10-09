#########################################################################
##                       Title: ACR OLD IMAGE DELETTION                ##
##                       version: V1.0.0 - 8/10/24                     ##
##                       Author: Ghost0shell                           ##
#########################################################################

## Deletion Rules:
##  - Older than 30 days
##    and
##  - more than one tag available
##    and
##  - not tag "latest"
##    and
##  - keeps the most recent tag

param($Timer)

$resourceGroupName = $env:TARGET_REGISTRY_RG
$acrName = $env:TARGET_REGISTRY
$dateThreshold = (Get-Date).AddMonths(-1)

$clientId = $env:CLIENT_ID
$clientSecret = $env:CLIENT_SECRET
$tenantId = "$env:TENANT_ID"

Write-Host "Registry Cleanup launched for '$acrName' in '$resourceGroupName'"

#az account clear
az login --service-principal -u $clientId -p $clientSecret --tenant $tenantId

$repositories = (az acr repository list --name $acrName --output json) | ConvertFrom-Json

foreach ($repo in $repositories) {
    $tags = az acr repository show-tags --name $acrName --repository $repo --output json --detail | ConvertFrom-Json
    if ( $tags.Count -gt 1 )
    {
        $mostRecentTag = $tags | Sort-Object { [datetime]::Parse($_.lastUpdateTime) } -Descending | Select-Object -First 1
        Write-Host "Most recent tag for '$repo': $($mostRecentTag.name), Last modified: $($mostRecentTag.lastUpdateTime)"
        
        foreach ($tag in $tags) {
            $tagName = $tag.name
            $lastModified = [datetime]::Parse($tag.lastUpdateTime)
            if ($lastModified -lt $dateThreshold) {
                if ($tagName -ne $mostRecentTag.name -and $tagName -ne "latest")
                {
                    $imageToDelete = "{0}:{1}" -f $repo, $tagName
                    az acr repository delete --name $acrName --image $imageToDelete --yes 2>&1
                    Write-Host "Successfully deleted image: $imageToDelete"
                }
                else 
                {
                    Write-Host "Skipping deletion for tag '$tagName' (it's either the most recent or 'latest')"
                }
            } 
            else 
            {
                Write-Host "Tag '$tagName' is less than 30 days -> keeping."
            }
        }
    }
}

