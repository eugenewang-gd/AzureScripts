$IPtoTest = Read-Host -Prompt "Enter IP to check"
# connect-azuread
Connect-MgGraph -Scopes 'Policy.Read.All'

# $namedLocations = Get-AzureADMSNamedLocationPolicy
$namedLocations = Get-MgIdentityConditionalAccessNamedLocation -Filter "isof('microsoft.graph.ipNamedLocation')"

$obj_NamedLocations = $namedLocations.Where({$_.AdditionalProperties.ipRanges.cidrAddress -ne $null}) | % {
    [pscustomobject]@{
        DisplayName = $_.displayname
        IPRanges = $_.AdditionalProperties.ipRanges.cidrAddress
        # IsTrusted = $_.isTrusted
        }
    }

function Check-IPAddress ($IPAddress, $Range){
 #src = https://github.com/omniomi/PSMailTools/blob/v0.2.0/src/Private/spf/IPInRange.ps1
# Split range into the address and the CIDR notation
    [String]$CIDRAddress = $Range.Split('/')[0]
    [int]$CIDRBits       = $Range.Split('/')[1]

    # Address from range and the search address are converted to Int32 and the full mask is calculated from the CIDR notation.
    [int]$BaseAddress    = [System.BitConverter]::ToInt32((([System.Net.IPAddress]::Parse($CIDRAddress)).GetAddressBytes()), 0)
    [int]$Address        = [System.BitConverter]::ToInt32(([System.Net.IPAddress]::Parse($IPAddress).GetAddressBytes()), 0)
    [int]$Mask           = [System.Net.IPAddress]::HostToNetworkOrder(-1 -shl ( 32 - $CIDRBits))

    # Determine whether the address is in the range.
    if (($BaseAddress -band $Mask) -eq ($Address -band $Mask)) {
        $true
    } else {
        $false
    }
    
}

$searchresult = $obj_namedLocations | Where-Object {($_.ipranges | % {Check-IPAddress $IPtoTest -Range $_}) -eq $true}
if (!($searchresult)){Write-Host -ForegroundColor Red "IP Address not a named location"}else{$searchresult, $searchresult.ipranges}