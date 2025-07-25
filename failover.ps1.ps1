# Step 1: Set Vault Context
$vaultName = "ZONE-VAULT-TEST"
$vaultRg = "RG-VAULT-TEST"

# Retrieve the Vault object
$vault = Get-AzRecoveryServicesVault -Name $vaultName -ResourceGroupName $vaultRg
# Set the Vault Context
Set-AzRecoveryServicesAsrVaultContext -Vault $vault
# Step 2: Check Vault Context
$vaultContext = Get-AzRecoveryServicesAsrVaultContext
if ($vaultContext -eq $null) {
    Write-Host " Vault Context is not set properly. Please check the vault configuration!" -ForegroundColor Red
    exit
} else {
    Write-Host " Vault Context set successfully!" -ForegroundColor Green
}
# Step 3: Fetch Fabrics
Write-Host "Fetching Fabrics..."
$fabrics = Get-AzRecoveryServicesAsrFabric | Where-Object { $_.FabricType -eq "Azure" }
# Check if any Azure fabric is available
if ($fabrics.Count -eq 0) {
    Write-Host " No Azure fabric found. Please check the Azure Site Recovery configuration!" -ForegroundColor Red
    exit
} else {
    Write-Host " Azure Fabrics found!" -ForegroundColor Green
}
# Step 4: Specify Primary Fabric Name
$primaryFabricName = ""
$primaryFabric = $fabrics | Where-Object { $_.FriendlyName -eq $primaryFabricName }
# If no primary fabric found, exit
if ($primaryFabric -eq $null) {
    Write-Host " No fabric found for '$primaryFabricName'. Please verify the fabric name!" -ForegroundColor Red
    exit
} else {
    Write-Host " Found Primary Fabric: $primaryFabricName" -ForegroundColor Green
}
# Step 5: Fetch Protection Containers
Write-Host "Fetching Protection Containers..."
$containers = Get-AzRecoveryServicesAsrProtectionContainer -Fabric $primaryFabric
# Check if containers exist
if ($containers.Count -eq 0) {
    Write-Host " No Protection Containers found. Please ensure protection is enabled for this fabric!" -ForegroundColor Red
    exit
} else {
    Write-Host " Protection Containers fetched!" -ForegroundColor Green
}
# Step 6: Define Target VMs for Planned Failover
$targetVMs = @("servername1","servername2")
 

# Step 7: Loop Through Protection Containers and Trigger Planned Failover
foreach ($container in $containers) {
    Write-Host "Processing Protection Container: $($container.Name)"
    $protectedItems = Get-AzRecoveryServicesAsrReplicationProtectedItem -ProtectionContainer $container
    foreach ($item in $protectedItems) {
        if ($targetVMs -contains $item.FriendlyName) {
            Write-Host " Starting Planned Failover for: $($item.FriendlyName)" -ForegroundColor Cyan
            $job = Start-AzRecoveryServicesAsrUnplannedFailoverJob `
                -ReplicationProtectedItem $item `
                -Direction "PrimaryToRecovery" `
				-PerformSourceSideActions:$true 
            Write-Host " Planned Failover triggered for $($item.FriendlyName) | Job ID: $($job.ID)" -ForegroundColor Green
        }
    }
}