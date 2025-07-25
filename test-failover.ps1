# Step 1: Set Vault Context
$vaultName = "ZONE-VAULT-TEST"
$vaultRg = "RG-VAULT-TEST"

# Retrieve the Vault object
$vault = Get-AzRecoveryServicesVault -Name $vaultName -ResourceGroupName $vaultRg

# Set the Vault Context (Make sure the vault object is retrieved correctly)
Set-AzRecoveryServicesAsrVaultContext -Vault $vault

# Step 2: Check if Vault Context is set correctly
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

# Step 4: Specify Primary Fabric Name (e.g., 'West US 2')
$primaryFabricName = "West US 2"
$primaryFabric = $fabrics | Where-Object { $_.FriendlyName -eq $primaryFabricName }

# If no primary fabric found, exit
if ($primaryFabric -eq $null) {
    Write-Host " No fabric found for '$primaryFabricName'. Please verify the fabric name!" -ForegroundColor Red
    exit
} else {
    Write-Host " Found Primary Fabric: $primaryFabricName" -ForegroundColor Green
}

# Step 5: Fetch Protection Containers (requires valid fabric)
Write-Host "Fetching Protection Containers..."
$containers = Get-AzRecoveryServicesAsrProtectionContainer -Fabric $primaryFabric

# Check if containers exist
if ($containers.Count -eq 0) {
    Write-Host " No Protection Containers found. Please ensure protection is enabled for this fabric!" -ForegroundColor Red
    exit
} else {
    Write-Host " Protection Containers fetched!" -ForegroundColor Green
}

# Step 6: Define Target VMs for Failover
$targetVMs = @("servername1","servername2")

# Step 7: Loop Through Protection Containers and Trigger Test Failover
foreach ($container in $containers) {
    Write-Host "Processing Protection Container: $($container.Name)"
    
    # Get replication protected items
    $protectedItems = Get-AzRecoveryServicesAsrReplicationProtectedItem -ProtectionContainer $container

    foreach ($item in $protectedItems) {
        # Check if the current protected item matches any target VM
        if ($targetVMs -contains $item.FriendlyName) {
            Write-Host " Starting Test Failover for: $($item.FriendlyName)" -ForegroundColor Cyan

            # Get the latest recovery point for the item
            $recoveryPoint = Get-AzRecoveryServicesAsrRecoveryPoint -ReplicationProtectedItem $item |
                             Sort-Object -Property CreatedTime -Descending |
                             Select-Object -First 1

            if ($recoveryPoint -eq $null) {
                Write-Warning " No recovery points found for $($item.FriendlyName). Skipping..." 
                continue
            }

            # Get VM Network from recovery Azure VM details
            $vmNetwork = "/subscriptions/....."

            # Start the Test Failover Job
            $job = Start-AzRecoveryServicesAsrTestFailoverJob `
                -ReplicationProtectedItem $item `
                -Direction "PrimaryToRecovery" `
                -RecoveryPoint $recoveryPoint `
                -AzureVMNetworkId $vmNetwork

            Write-Host " Test Failover triggered for $($item.FriendlyName) | Job ID: $($job.ID)" -ForegroundColor Green
        }
    }
}



