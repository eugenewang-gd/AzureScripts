Connect-MgGraph -Scopes 'Policy.Read.All'
$namedLocations = Get-MgIdentityConditionalAccessNamedLocation -Filter "isof('microsoft.graph.ipNamedLocation')"
foreach ($namedLocation in $namedLocations) {
    Write-Host "Named location ID: $($namedLocation.id)"
    Write-Host "Named location display name: $($namedLocation.displayName)"
    Write-Host "IP addresses:"
    foreach ($ipRange in $namedLocation.AdditionalProperties.ipRanges) {
        Write-Host "  $($ipRange.cidrAddress)"
    }
}