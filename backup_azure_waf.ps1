# Define WAF policy pairs
$WAFPolicies = @(
    @{ WAFType = "FrontDoor"; SubscriptionId = "0754aa07-6108-47ba-94ee-7823b5bf0bfe"; ResourceGroup = "np-GEN-EUS-WAF-FD-RG"; WAFPolicyName = "npfdglblgen001waf" },
    @{ WAFType = "FrontDoor"; SubscriptionId = "0754aa07-6108-47ba-94ee-7823b5bf0bfe"; ResourceGroup = "np-gen-eus-waf-fd-rg"; WAFPolicyName = "npfdglblcdn001waf" },
    @{ WAFType = "WebApplicationGateway"; SubscriptionId = "c9f63361-7d6b-406d-ab34-d193554943d3"; ResourceGroup = "PD-GEN-EUS-WAF-AGW-RG"; WAFPolicyName = "pdagweusgen001waf" },
    @{ WAFType = "WebApplicationGateway"; SubscriptionId = "c9f63361-7d6b-406d-ab34-d193554943d3"; ResourceGroup = "PD-GEN-WUS3-WAF-AGW-RG"; WAFPolicyName = "pdagwwus3gen001waf" },
    @{ WAFType = "FrontDoor"; SubscriptionId = "c9f63361-7d6b-406d-ab34-d193554943d3"; ResourceGroup = "pd-gen-eus-waf-fd-rg"; WAFPolicyName = "pdfdglblgen001waf" },
	@{ WAFType = "FrontDoor"; SubscriptionId = "c9f63361-7d6b-406d-ab34-d193554943d3"; ResourceGroup = "pd-gen-eus-waf-fd-rg"; WAFPolicyName = "pdfdglblcdn001waf" },
    @{ WAFType = "WebApplicationGateway"; SubscriptionId = "0754aa07-6108-47ba-94ee-7823b5bf0bfe"; ResourceGroup = "np-GEN-EUS-WAF-AGW-RG"; WAFPolicyName = "npagweusgen001waf" },
    @{ WAFType = "WebApplicationGateway"; SubscriptionId = "0754aa07-6108-47ba-94ee-7823b5bf0bfe"; ResourceGroup = "np-GEN-WUS3-WAF-AGW-RG"; WAFPolicyName = "npagwwus3gen001waf" }
)

# Function to display WAF policy pairs
function Display-WAFPolicies {
    $WAFPolicies | ForEach-Object { 
        $index = [array]::IndexOf($WAFPolicies, $_)
        $output = "{0}: WAFType={1}, SubscriptionId={2}, ResourceGroup={3}, WAFPolicyName={4}" -f $index, $_.WAFType, $_.SubscriptionId, $_.ResourceGroup, $_.WAFPolicyName
        Write-Output $output
    }
}

# Function to backup WAF policy
function Backup-WAFPolicy {
    param (
        [hashtable]$WAFPolicy
    )
    # Login to Azure
    Connect-AzAccount -SubscriptionId $WAFPolicy.SubscriptionId

    # Get the WAF policy
    if ($WAFPolicy.WAFType -eq "FrontDoor") {
        $Policy = Get-AzFrontDoorWafPolicy -ResourceGroupName $WAFPolicy.ResourceGroup -Name $WAFPolicy.WAFPolicyName
    } elseif ($WAFPolicy.WAFType -eq "WebApplicationGateway") {
        $Policy = Get-AzApplicationGatewayFirewallPolicy -ResourceGroupName $WAFPolicy.ResourceGroup -Name $WAFPolicy.WAFPolicyName
    } else {
        Write-Output "Invalid WAF Type"
        return
    }

    # Export the WAF policy to a JSON file
    $Policy | ConvertTo-Json -Depth 10 | Out-File "$($WAFPolicy.WAFPolicyName)-backup.json"
    Write-Output "Backup completed: $($WAFPolicy.WAFPolicyName)-backup.json"
}

# Function to restore WAF policy
function Restore-WAFPolicy {
    param (
        [hashtable]$WAFPolicy
    )
    # Login to Azure
    Connect-AzAccount -SubscriptionId $WAFPolicy.SubscriptionId

    # Import the WAF policy from a JSON file
    $PolicyJson = Get-Content "$($WAFPolicy.WAFPolicyName)-backup.json" -Raw | ConvertFrom-Json

    # Restore the WAF policy
    if ($WAFPolicy.WAFType -eq "FrontDoor") {
        New-AzFrontDoorWafPolicy -ResourceGroupName $WAFPolicy.ResourceGroup -Name $WAFPolicy.WAFPolicyName -PolicySettings $PolicyJson.PolicySettings
    } elseif ($WAFPolicy.WAFType -eq "WebApplicationGateway") {
        New-AzApplicationGatewayWebApplicationFirewallPolicy -ResourceGroupName $WAFPolicy.ResourceGroup -Name $WAFPolicy.WAFPolicyName -PolicySettings $PolicyJson.PolicySettings
    } else {
        Write-Output "Invalid WAF Type"
        return
    }

    Write-Output "Restore completed: $($WAFPolicy.WAFPolicyName)"
}

# Main script
Display-WAFPolicies
$Selection = Read-Host "Select a WAF policy pair by index"
$SelectedWAFPolicy = $WAFPolicies[$Selection]

$Action = Read-Host "Do you want to Backup or Restore? (Backup/Restore)"

if ($Action -eq "Backup") {
    Backup-WAFPolicy -WAFPolicy $SelectedWAFPolicy
} elseif ($Action -eq "Restore") {
    Restore-WAFPolicy -WAFPolicy $SelectedWAFPolicy
} else {
    Write-Output "Invalid action. Please enter 'Backup' or 'Restore'."
}

