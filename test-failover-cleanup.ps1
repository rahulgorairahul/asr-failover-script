# ================================
# ASR Test Failover Cleanup Script (Final, Working Version)
# ================================

# Step 1: Set Vault Context
$vaultName = "ZONE-VAULT-TEST"
$vaultRg = "RG-VAULT-TEST"

$vault = Get-AzRecoveryServicesVault -Name $vaultName -ResourceGroupName $vaultRg
Set-AzRecoveryServicesAsrVaultContext -Vault $vault

# Step 2: Confirm Vault Context
$vaultContext = Get-AzRecoveryServicesAsrVaultContext
if ($vaultContext -eq $null) {
    Write-Host " Vault Context is not set properly." -ForegroundColor Red
    exit
} else {
    Write-Host " Vault Context set successfully!" -ForegroundColor Green
}

# Step 3: Get Azure Fabrics
Write-Host " Fetching Fabrics..."
$fabrics = Get-AzRecoveryServicesAsrFabric | Where-Object { $_.FabricType -eq "Azure" }

$primaryFabricName = "West US 2"
$primaryFabric = $fabrics | Where-Object { $_.FriendlyName -eq $primaryFabricName }

if ($primaryFabric -eq $null) {
    Write-Host " Primary fabric not found!" -ForegroundColor Red
    exit
} else {
    Write-Host " Found Primary Fabric: $primaryFabricName" -ForegroundColor Green
}

# Step 4: Get Protection Containers
Write-Host " Fetching Protection Containers..."
$containers = Get-AzRecoveryServicesAsrProtectionContainer -Fabric $primaryFabric

if ($containers.Count -eq 0) {
    Write-Host " No Protection Containers found!" -ForegroundColor Red
    exit
} else {
    Write-Host " Protection Containers fetched!" -ForegroundColor Green
}

# Step 5: Define Target VMs to Cleanup
$targetVMs = @("servername1","servername2")

# Step 6: Loop through containers and initiate cleanup
foreach ($container in $containers) {
    $protectedItems = Get-AzRecoveryServicesAsrReplicationProtectedItem -ProtectionContainer $container

    foreach ($item in $protectedItems) {
        if ($targetVMs -contains $item.FriendlyName) {
            Write-Host " Initiating Test Failover Cleanup for: $($item.FriendlyName)" -ForegroundColor Yellow

            #  Corrected: Removed invalid '-Comments' parameter
            $cleanupJob = Start-AzRecoveryServicesAsrTestFailoverCleanupJob `
                -ReplicationProtectedItem $item

            Write-Host " Cleanup started for $($item.FriendlyName) | Job ID: $($cleanupJob.ID)" -ForegroundColor Green
        }
    }
}
