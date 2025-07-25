# ASR Failover Automation Scripts
This GitHub repository contains PowerShell scripts to automate Azure Site Recovery (ASR) operations:
## 🔹 Scripts
| Script | Purpose |
|--------|---------|
| `test-failover.ps1` | Automates test failover for protected VMs |
| `failover.ps1` | Executes planned or unplanned failover |
| `test-failover-cleanup.ps1` | Cleans up resources after test failover |
## 🚀 Usage
Run from PowerShell with Azure Az module:
```powershell
.\scripts\test-failover.ps1
.\scripts\failover.ps1
.\scripts\test-failover-cleanup.ps1
