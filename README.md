# 🔁 Azure Site Recovery (ASR) Failover Automation Scripts

This repository contains PowerShell scripts that automate the entire **Azure Site Recovery (ASR)** lifecycle, including:

- ✅ **Test Failover**
- 🧹 **Test Failover Cleanup**
- ⚠️ **Actual Failover**

These scripts are designed to help cloud administrators save time and reduce manual effort during disaster recovery (DR) drills and real-world failover events.

---

## 📁 Scripts Overview

| Script                          | Purpose                                      |
|---------------------------------|----------------------------------------------|
| `test-failover.ps1`             | Automates the ASR Test Failover process      |
| `test-failover-cleanup.ps1`     | Cleans up test failover VMs and resources    |
| `failover.ps1`                  | Initiates an actual planned/unplanned failover |

---

## 🧰 Features

- Automates failover across multiple VMs
- Supports test failover and cleanup in one click
- Error handling and execution status logs
- Easy to integrate with Azure Runbooks or pipelines

---

## ⚙️ Requirements

- PowerShell 7.x (Recommended)
- Azure PowerShell Modules installed:
  - `Az.RecoveryServices`
  - `Az.Accounts`
- Logged into Azure (`Connect-AzAccount`)

---

## 🚀 How to Use

```powershell
# Step 1: Login to Azure
Connect-AzAccount

# Step 2: Run Test Failover
.\scripts\test-failover.ps1

# Step 3: Run Cleanup after test
.\scripts\test-failover-cleanup.ps1

# Step 4: Perform Actual Failover
.\scripts\failover.ps1