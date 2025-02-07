# Install Microsoft Graph PowerShell module if not already installed
# Install-Module Microsoft.Graph -Force

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "Policy.Read.All"


# Retrieve and export Conditional Access policies with detailed settings
$policies = Get-MgIdentityConditionalAccessPolicy
$policyDetails = @()

foreach ($policy in $policies) {
    $policyDetail = Get-MgIdentityConditionalAccessPolicy -ConditionalAccessPolicyId $policy.Id
    $policyDetails += [PSCustomObject]@{
        Id               = $policyDetail.Id
        DisplayName      = $policyDetail.DisplayName
        Description      = $policyDetail.Description
        State            = $policyDetail.State
        CreatedDateTime  = $policyDetail.CreatedDateTime
        ModifiedDateTime = $policyDetail.ModifiedDateTime
        Conditions       = $policyDetail.Conditions | Select-Object -Property *
        GrantControls    = $policyDetail.GrantControls | Select-Object -Property *
        SessionControls  = $policyDetail.SessionControls | Select-Object -Property *
    }
}

$policyDetails | ConvertTo-Json -Depth 10 | Out-File -FilePath "C:\Users\eugene.wang\OneDrive - GREEN DOT CORPORATION\Documents\Office Scripts\ConditionalAccessPoliciesWithSettings.json"
