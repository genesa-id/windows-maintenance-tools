<#
    Genesa Windows Maintenance Tool - GUI + Progress Edition (Enhanced)
    Author: Badia Tarigan - Genesa DevOps Team
    Version: 6.0
    Compatible: Windows 10 / 11 (Workgroup)
#>

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# =====================================
# Global Variables
# =====================================
$script:cancellationRequested = $false
$script:totalSpaceFreed = 0
$script:operationResults = @{}

# =====================================
# Privilege Check
# =====================================
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    [System.Windows.Forms.MessageBox]::Show(
        "Please run this script as Administrator.",
        "Permission Required", [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    )
    exit
}

# =====================================
# Logging Setup
# =====================================
$logPath = "C:\MaintenanceLogs"
if (!(Test-Path $logPath)) { 
    try { 
        New-Item -Path $logPath -ItemType Directory -Force | Out-Null 
        Write-Host "Created log directory: $logPath"
    } catch {
        [System.Windows.Forms.MessageBox]::Show(
            "Failed to create log directory: $($_.Exception.Message)",
            "Error", [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        )
        exit
    }
}

$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$logFile = "$logPath\maintenance_$timestamp.txt"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $logEntry = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [$Level] $Message"
    Add-Content -Path $logFile -Value $logEntry -ErrorAction SilentlyContinue
    Write-Host $logEntry
}

try {
    Start-Transcript -Path $logFile -Append
    Write-Log "=== Maintenance Session Started ===" "INFO"
} catch {
    Write-Host "Warning: Could not start transcript. Logging may be limited."
}

# =====================================
# GUI Layout
# =====================================
$form = New-Object System.Windows.Forms.Form
$form.Text = "Genesa Windows Maintenance Tool v6.0"
$form.Size = New-Object System.Drawing.Size(580,680)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.Font = 'Segoe UI,10'

$lblTitle = New-Object System.Windows.Forms.Label
$lblTitle.Text = "Select maintenance actions to run:"
$lblTitle.AutoSize = $true
$lblTitle.Location = New-Object System.Drawing.Point(20,20)
$lblTitle.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($lblTitle)

# =====================================
# Checkboxes
# =====================================
$actions = @(
    @{Text="1. Clean temporary files";Var="chkTemp"},
    @{Text="2. Disk Cleanup";Var="chkDisk"},
    @{Text="3. Optimize Drives";Var="chkOptimize"},
    @{Text="4. System File Check (SFC/DISM)";Var="chkSFC"},
    @{Text="5. Windows Updates";Var="chkUpdate"},
    @{Text="6. Clear Windows Update Cache";Var="chkCache"},
    @{Text="7. Browser Cache Cleanup";Var="chkBrowser"},
    @{Text="8. Delete Old Logs (>30 days)";Var="chkLogs"}
)

$y = 55
foreach ($a in $actions) {
    $cb = New-Object System.Windows.Forms.CheckBox
    $cb.Text = $a.Text
    $cb.Location = New-Object System.Drawing.Point(30,$y)
    $cb.Width = 500
    $cb.Height = 30
    Set-Variable -Name $a.Var -Value $cb
    $form.Controls.Add($cb)
    $y += 32
}

# Select All / Deselect All buttons
$btnSelectAll = New-Object System.Windows.Forms.Button
$btnSelectAll.Text = "Select All"
$btnSelectAll.Location = New-Object System.Drawing.Point(30, 320)
$btnSelectAll.Width = 100
$btnSelectAll.Height = 28

$btnDeselectAll = New-Object System.Windows.Forms.Button
$btnDeselectAll.Text = "Deselect All"
$btnDeselectAll.Location = New-Object System.Drawing.Point(140, 320)
$btnDeselectAll.Width = 100
$btnDeselectAll.Height = 28

# =====================================
# Progress Components
# =====================================
$lblProgressTitle = New-Object System.Windows.Forms.Label
$lblProgressTitle.Text = "Progress:"
$lblProgressTitle.AutoSize = $true
$lblProgressTitle.Location = New-Object System.Drawing.Point(30, 360)
$lblProgressTitle.Font = New-Object System.Drawing.Font('Segoe UI', 9, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($lblProgressTitle)

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(30, 380)
$progressBar.Size = New-Object System.Drawing.Size(520, 25)
$progressBar.Style = "Continuous"
$progressBar.Minimum = 0
$progressBar.Maximum = 100
$form.Controls.Add($progressBar)

$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Location = New-Object System.Drawing.Point(30, 410)
$lblStatus.Size = New-Object System.Drawing.Size(520, 25)
$lblStatus.Text = "Ready. Select tasks and click 'Run Selected Tasks' to begin."
$form.Controls.Add($lblStatus)

$lblStats = New-Object System.Windows.Forms.Label
$lblStats.Location = New-Object System.Drawing.Point(30, 435)
$lblStats.Size = New-Object System.Drawing.Size(520, 20)
$lblStats.Text = "Space freed: 0 MB"
$lblStats.ForeColor = [System.Drawing.Color]::DarkGreen
$lblStats.Font = New-Object System.Drawing.Font('Segoe UI', 9)
$form.Controls.Add($lblStats)

$txtLog = New-Object System.Windows.Forms.TextBox
$txtLog.Multiline = $true
$txtLog.ScrollBars = "Vertical"
$txtLog.ReadOnly = $true
$txtLog.Location = New-Object System.Drawing.Point(30, 460)
$txtLog.Size = New-Object System.Drawing.Size(520, 140)
$txtLog.Font = New-Object System.Drawing.Font('Consolas', 8)
$form.Controls.Add($txtLog)

function Write-UI($msg, [string]$color = "Black") {
    $timestamp = Get-Date -Format 'HH:mm:ss'
    $logText = "[$timestamp] $msg`r`n"
    
    # Note: TextBox doesn't support per-character colors in PowerShell Forms
    # We'll use a simple approach and log to file with color info
    $txtLog.AppendText($logText)
    $txtLog.SelectionStart = $txtLog.Text.Length
    $txtLog.ScrollToCaret()
    $form.Refresh()
    Write-Log $msg
    [System.Windows.Forms.Application]::DoEvents()
}

function Update-Progress($percent, $status) {
    $progressBar.Value = [Math]::Min([Math]::Max($percent, 0), 100)
    $lblStatus.Text = $status
    $form.Refresh()
    [System.Windows.Forms.Application]::DoEvents()
}

function Update-Stats($spaceFreedMB) {
    $script:totalSpaceFreed += $spaceFreedMB
    $formattedSize = "{0:N2}" -f $script:totalSpaceFreed
    if ($script:totalSpaceFreed -gt 1024) {
        $lblStats.Text = "Space freed: $($formattedSize / 1024) GB"
    } else {
        $lblStats.Text = "Space freed: $formattedSize MB"
    }
    $form.Refresh()
}

function Format-Size($bytes) {
    if ($bytes -eq $null -or $bytes -eq 0) { return "0 MB" }
    $mb = $bytes / 1MB
    if ($mb -gt 1024) {
        return "{0:N2} GB" -f ($mb / 1024)
    } else {
        return "{0:N2} MB" -f $mb
    }
}

# =====================================
# Buttons
# =====================================
$btnRun = New-Object System.Windows.Forms.Button
$btnRun.Text = "Run Selected Tasks"
$btnRun.Location = New-Object System.Drawing.Point(260, 320)
$btnRun.Width = 140
$btnRun.Height = 28

$btnCancel = New-Object System.Windows.Forms.Button
$btnCancel.Text = "Cancel"
$btnCancel.Location = New-Object System.Drawing.Point(410, 320)
$btnCancel.Width = 100
$btnCancel.Height = 28
$btnCancel.Enabled = $false

$btnExit = New-Object System.Windows.Forms.Button
$btnExit.Text = "Exit"
$btnExit.Location = New-Object System.Drawing.Point(450, 610)
$btnExit.Width = 100
$btnExit.Height = 28

$form.Controls.AddRange(@($btnRun, $btnCancel, $btnExit, $btnSelectAll, $btnDeselectAll))

# =====================================
# Core Maintenance Functions
# =====================================

function Clean-Temp {
    if ($script:cancellationRequested) { return $false }
    Update-Progress 10 "Cleaning temporary files..."
    Write-UI "Cleaning temporary files..." "Blue"
    
    $totalFreed = 0
    $targets = @(
        "C:\Windows\Temp",
        $env:TEMP,
        "$env:LOCALAPPDATA\Temp",
        "C:\Users\$env:USERNAME\AppData\Local\Temp"
    )
    
    foreach ($t in $targets) {
        if ($script:cancellationRequested) { return $false }
        if (Test-Path $t) {
            try {
                $files = Get-ChildItem -Path $t -Recurse -File -ErrorAction SilentlyContinue
                $sizeBefore = ($files | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
                if ($sizeBefore) {
                    Remove-Item -Path "$t\*" -Recurse -Force -ErrorAction SilentlyContinue
                    $totalFreed += ($sizeBefore / 1MB)
                    Write-UI "  Cleaned: $t - $(Format-Size $sizeBefore)" "Green"
                }
            } catch {
                Write-UI "  Warning: Could not clean $t - $($_.Exception.Message)" "Orange"
                Write-Log "Error cleaning $t : $($_.Exception.Message)" "ERROR"
            }
        }
    }
    
    Update-Stats $totalFreed
    $script:operationResults['TempFiles'] = @{ Success = $true; SpaceFreed = $totalFreed }
    Write-UI "Temporary files cleaned. Freed: $(Format-Size ($totalFreed * 1MB))" "Green"
    return $true
}

function Run-DiskCleanup {
    if ($script:cancellationRequested) { return $false }
    Update-Progress 25 "Running Disk Cleanup..."
    Write-UI "Running Disk Cleanup (this may take several minutes)..." "Blue"
    
    # Calculate drive space before cleanup
    $drive = Get-PSDrive -Name "C" -ErrorAction SilentlyContinue
    $spaceBefore = 0
    if ($drive) {
        try {
            $spaceBefore = ($drive.Free) / 1MB
            Write-UI "  Checking drive space before cleanup..." "Blue"
        } catch {
            Write-UI "  Could not calculate initial drive space." "Orange"
        }
    }
    
    try {
        $process = Start-Process cleanmgr -ArgumentList "/sagerun:99" -PassThru -WindowStyle Hidden -ErrorAction Stop
        Write-UI "  Disk Cleanup process started. Please wait..." "Blue"
        
        while (-not $process.HasExited) {
            if ($script:cancellationRequested) {
                Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
                Write-UI "Disk Cleanup cancelled by user." "Orange"
                return $false
            }
            Start-Sleep -Milliseconds 500
            [System.Windows.Forms.Application]::DoEvents()
        }
        
        # Calculate drive space after cleanup
        $spaceAfter = 0
        $spaceFreed = 0
        if ($drive) {
            try {
                Start-Sleep -Seconds 2  # Wait for cleanup to fully complete
                $drive = Get-PSDrive -Name "C" -ErrorAction SilentlyContinue
                $spaceAfter = ($drive.Free) / 1MB
                $spaceFreed = $spaceAfter - $spaceBefore
                
                if ($spaceFreed -gt 0) {
                    Update-Stats $spaceFreed
                    Write-UI "  Disk Cleanup freed approximately $(Format-Size ($spaceFreed * 1MB))" "Green"
                    $script:operationResults['DiskCleanup'] = @{ Success = $true; ExitCode = $process.ExitCode; SpaceFreed = $spaceFreed }
                } else {
                    Write-UI "  Disk Cleanup completed. No significant space freed (may already be clean)." "Green"
                    $script:operationResults['DiskCleanup'] = @{ Success = $true; ExitCode = $process.ExitCode; SpaceFreed = 0; Note = "Disk may already be clean" }
                }
            } catch {
                Write-UI "  Disk Cleanup completed. Could not calculate freed space." "Orange"
                $script:operationResults['DiskCleanup'] = @{ Success = $true; ExitCode = $process.ExitCode; SpaceFreed = 0; Note = "Space calculation unavailable" }
            }
        } else {
            $script:operationResults['DiskCleanup'] = @{ Success = $true; ExitCode = $process.ExitCode; SpaceFreed = 0; Note = "Space calculation unavailable" }
        }
        
        Write-UI "Disk Cleanup completed successfully." "Green"
        return $true
    } catch {
        Write-UI "Disk Cleanup failed: $($_.Exception.Message)" "Red"
        Write-Log "Disk Cleanup error: $($_.Exception.Message)" "ERROR"
        $script:operationResults['DiskCleanup'] = @{ Success = $false; Error = $_.Exception.Message }
        return $false
    }
}

function Optimize-Drives {
    if ($script:cancellationRequested) { return $false }
    Update-Progress 40 "Optimizing drives..."
    Write-UI "Optimizing drives (this may take a while)..." "Blue"
    
    $drives = Get-Volume | Where-Object { $_.DriveLetter -and $_.DriveType -eq 'Fixed' }
    $driveCount = ($drives | Measure-Object).Count
    $current = 0
    
    foreach ($vol in $drives) {
        if ($script:cancellationRequested) { return $false }
        $current++
        $driveLetter = $vol.DriveLetter
        $progress = 40 + [int](($current / $driveCount) * 10)
        
        try {
            Update-Progress $progress "Optimizing drive $driveLetter`: ($current/$driveCount)..."
            Write-UI "  Optimizing drive $driveLetter`:" "Blue"
            
            $result = Optimize-Volume -DriveLetter $driveLetter -ReTrim -ErrorAction Stop
            Write-UI "    Drive $driveLetter`: optimized successfully" "Green"
            Write-Log "Drive $driveLetter`: optimized" "INFO"
        } catch {
            Write-UI "    Warning: Could not optimize drive $driveLetter`: - $($_.Exception.Message)" "Orange"
            Write-Log "Drive optimization error for $driveLetter`: $($_.Exception.Message)" "ERROR"
        }
    }
    
    $script:operationResults['OptimizeDrives'] = @{ Success = $true; DrivesProcessed = $current }
    Write-UI "Drive optimization complete. Processed $current drive(s)." "Green"
    return $true
}

function Run-SFC {
    if ($script:cancellationRequested) { return $false }
    Update-Progress 55 "Running SFC scan..."
    Write-UI "Running System File Checker (SFC)..." "Blue"
    Write-UI "  This may take 10-30 minutes. Please be patient..." "Blue"
    
    try {
        $sfcProcess = Start-Process -FilePath "sfc.exe" -ArgumentList "/scannow" -PassThru -NoNewWindow -Wait -ErrorAction Stop
        if ($sfcProcess.ExitCode -eq 0) {
            Write-UI "  SFC scan completed successfully." "Green"
        } else {
            Write-UI "  SFC scan completed with exit code: $($sfcProcess.ExitCode)" "Orange"
        }
    } catch {
        Write-UI "  SFC scan failed: $($_.Exception.Message)" "Red"
        Write-Log "SFC error: $($_.Exception.Message)" "ERROR"
        return $false
    }
    
    if ($script:cancellationRequested) { return $false }
    Update-Progress 60 "Running DISM..."
    Write-UI "Running DISM health check..." "Blue"
    
    try {
        $dismProcess = Start-Process -FilePath "DISM.exe" -ArgumentList "/Online", "/Cleanup-Image", "/RestoreHealth" -PassThru -NoNewWindow -Wait -ErrorAction Stop
        if ($dismProcess.ExitCode -eq 0) {
            Write-UI "  DISM health check completed successfully." "Green"
        } else {
            Write-UI "  DISM completed with exit code: $($dismProcess.ExitCode)" "Orange"
        }
    } catch {
        Write-UI "  DISM check failed: $($_.Exception.Message)" "Red"
        Write-Log "DISM error: $($_.Exception.Message)" "ERROR"
        return $false
    }
    
    $script:operationResults['SFC'] = @{ Success = $true }
    Write-UI "System file integrity check completed." "Green"
    return $true
}

function Run-Update {
    if ($script:cancellationRequested) { return $false }
    Update-Progress 70 "Checking for Windows Updates..."
    Write-UI "Checking for Windows Updates..." "Blue"
    
    if (Get-Module -ListAvailable -Name PSWindowsUpdate) {
        try {
            Import-Module PSWindowsUpdate -ErrorAction Stop
            Write-UI "  PSWindowsUpdate module loaded." "Blue"
            
            $updates = Get-WUList -ErrorAction SilentlyContinue
            if ($updates) {
                Write-UI "  Found $($updates.Count) update(s). Installing..." "Blue"
                $result = Install-WindowsUpdate -AcceptAll -IgnoreReboot -ErrorAction Stop
                Write-UI "  Updates installed successfully." "Green"
                $script:operationResults['WindowsUpdate'] = @{ Success = $true; UpdatesInstalled = $updates.Count }
            } else {
                Write-UI "  No updates available." "Green"
                $script:operationResults['WindowsUpdate'] = @{ Success = $true; UpdatesInstalled = 0 }
            }
        } catch {
            Write-UI "  Update check/install failed: $($_.Exception.Message)" "Red"
            Write-Log "Windows Update error: $($_.Exception.Message)" "ERROR"
            Write-UI "  Opening Windows Update Settings..." "Blue"
            Start-Process "ms-settings:windowsupdate"
            $script:operationResults['WindowsUpdate'] = @{ Success = $false; Error = $_.Exception.Message }
            return $false
        }
    } else {
        Write-UI "PSWindowsUpdate module not found." "Orange"
        Write-UI "Opening Windows Update Settings..." "Blue"
        Start-Process "ms-settings:windowsupdate"
        $script:operationResults['WindowsUpdate'] = @{ Success = $false; Note = "Manual update required" }
        return $false
    }
    return $true
}

function Clear-UpdateCache {
    if ($script:cancellationRequested) { return $false }
    Update-Progress 80 "Clearing Windows Update cache..."
    Write-UI "Clearing Windows Update cache..." "Blue"
    
    $cachePath = "C:\Windows\SoftwareDistribution\Download"
    $sizeBefore = 0
    
    if (Test-Path $cachePath) {
        try {
            $files = Get-ChildItem -Path $cachePath -Recurse -File -ErrorAction SilentlyContinue
            $sizeBefore = ($files | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
        } catch {
            Write-UI "  Could not calculate cache size." "Orange"
        }
    }
    
    try {
        Write-UI "  Stopping Windows Update services..." "Blue"
        Stop-Service wuauserv -Force -ErrorAction Stop
        Stop-Service bits -Force -ErrorAction Stop
        Start-Sleep -Seconds 2
        
        if (Test-Path $cachePath) {
            Write-UI "  Removing cache files..." "Blue"
            Remove-Item "$cachePath\*" -Recurse -Force -ErrorAction Stop
        }
        
        Write-UI "  Restarting services..." "Blue"
        Start-Service wuauserv -ErrorAction Stop
        Start-Service bits -ErrorAction Stop
        
        $spaceFreedMB = ($sizeBefore / 1MB)
        Update-Stats $spaceFreedMB
        $script:operationResults['UpdateCache'] = @{ Success = $true; SpaceFreed = $spaceFreedMB }
        Write-UI "Windows Update cache cleared. Freed: $(Format-Size $sizeBefore)" "Green"
        return $true
    } catch {
        Write-UI "Failed to clear update cache: $($_.Exception.Message)" "Red"
        Write-Log "Update cache clear error: $($_.Exception.Message)" "ERROR"
        
        # Try to restart services even if cleanup failed
        try {
            Start-Service wuauserv -ErrorAction SilentlyContinue
            Start-Service bits -ErrorAction SilentlyContinue
        } catch {}
        
        $script:operationResults['UpdateCache'] = @{ Success = $false; Error = $_.Exception.Message }
        return $false
    }
}

function Clear-BrowserCache {
    if ($script:cancellationRequested) { return $false }
    Update-Progress 90 "Cleaning browser cache..."
    Write-UI "Cleaning browser cache..." "Blue"
    
    $totalFreed = 0
    $browsers = @(
        @{ Name = "Chrome"; Path = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache" },
        @{ Name = "Edge"; Path = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache" },
        @{ Name = "Firefox"; Path = "$env:APPDATA\Mozilla\Firefox\Profiles" }
    )
    
    foreach ($browser in $browsers) {
        if ($script:cancellationRequested) { return $false }
        
        if ($browser.Name -eq "Firefox") {
            # Handle Firefox profiles
            $profiles = Get-ChildItem -Path $browser.Path -Directory -ErrorAction SilentlyContinue
            foreach ($profile in $profiles) {
                $cachePath = Join-Path $profile.FullName "cache2"
                if (Test-Path $cachePath) {
                    try {
                        $files = Get-ChildItem -Path $cachePath -Recurse -File -ErrorAction SilentlyContinue
                        $sizeBefore = ($files | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
                        Remove-Item "$cachePath\*" -Recurse -Force -ErrorAction Stop
                        $totalFreed += ($sizeBefore / 1MB)
                        Write-UI "  Firefox ($($profile.Name)): Freed $(Format-Size $sizeBefore)" "Green"
                    } catch {
                        Write-UI "  Firefox ($($profile.Name)): Error - $($_.Exception.Message)" "Orange"
                    }
                }
            }
        } else {
            # Chrome and Edge
            if (Test-Path $browser.Path) {
                try {
                    $files = Get-ChildItem -Path $browser.Path -Recurse -File -ErrorAction SilentlyContinue
                    $sizeBefore = ($files | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
                    Remove-Item "$($browser.Path)\*" -Recurse -Force -ErrorAction Stop
                    $totalFreed += ($sizeBefore / 1MB)
                    Write-UI "  $($browser.Name): Freed $(Format-Size $sizeBefore)" "Green"
                } catch {
                    Write-UI "  $($browser.Name): Error - $($_.Exception.Message)" "Orange"
                    Write-Log "$($browser.Name) cache error: $($_.Exception.Message)" "ERROR"
                }
            }
        }
    }
    
    Update-Stats $totalFreed
    $script:operationResults['BrowserCache'] = @{ Success = $true; SpaceFreed = $totalFreed }
    Write-UI "Browser cache cleaned. Total freed: $(Format-Size ($totalFreed * 1MB))" "Green"
    return $true
}

function Cleanup-Logs {
    if ($script:cancellationRequested) { return $false }
    Update-Progress 95 "Cleaning old logs..."
    Write-UI "Cleaning old logs (older than 30 days)..." "Blue"
    
    try {
        $cutoffDate = (Get-Date).AddDays(-30)
        $oldLogs = Get-ChildItem -Path $logPath -Recurse -File -ErrorAction SilentlyContinue | 
            Where-Object { $_.LastWriteTime -lt $cutoffDate }
        
        if ($oldLogs) {
            $sizeBefore = ($oldLogs | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
            $count = ($oldLogs | Measure-Object).Count
            
            $oldLogs | Remove-Item -Force -ErrorAction Stop
            $spaceFreedMB = ($sizeBefore / 1MB)
            
            Update-Stats $spaceFreedMB
            Write-UI "  Removed $count old log file(s). Freed: $(Format-Size $sizeBefore)" "Green"
            $script:operationResults['Logs'] = @{ Success = $true; FilesRemoved = $count; SpaceFreed = $spaceFreedMB }
        } else {
            Write-UI "  No old logs found to remove." "Green"
            $script:operationResults['Logs'] = @{ Success = $true; FilesRemoved = 0 }
        }
        return $true
    } catch {
        Write-UI "Failed to clean old logs: $($_.Exception.Message)" "Red"
        Write-Log "Log cleanup error: $($_.Exception.Message)" "ERROR"
        $script:operationResults['Logs'] = @{ Success = $false; Error = $_.Exception.Message }
        return $false
    }
}

# =====================================
# Button Event Handlers
# =====================================

$btnSelectAll.Add_Click({
    foreach ($c in @($chkTemp,$chkDisk,$chkOptimize,$chkSFC,$chkUpdate,$chkCache,$chkBrowser,$chkLogs)) {
        $c.Checked = $true
    }
})

$btnDeselectAll.Add_Click({
    foreach ($c in @($chkTemp,$chkDisk,$chkOptimize,$chkSFC,$chkUpdate,$chkCache,$chkBrowser,$chkLogs)) {
        $c.Checked = $false
    }
})

$btnCancel.Add_Click({
    $script:cancellationRequested = $true
    Write-UI "Cancellation requested. Finishing current task..." "Orange"
    $btnCancel.Enabled = $false
})

$btnRun.Add_Click({
    # Reset state
    $script:cancellationRequested = $false
    $script:totalSpaceFreed = 0
    $script:operationResults = @{}
    $txtLog.Clear()
    $lblStats.Text = "Space freed: 0 MB"
    
    Write-UI "=== Starting Maintenance ===" "Blue"
    Update-Progress 0 "Initializing..."

    # Disable controls during execution
    $btnRun.Enabled = $false
    $btnSelectAll.Enabled = $false
    $btnDeselectAll.Enabled = $false
    $btnCancel.Enabled = $true
    
    foreach ($c in @($chkTemp,$chkDisk,$chkOptimize,$chkSFC,$chkUpdate,$chkCache,$chkBrowser,$chkLogs)) {
        $c.Enabled = $false
    }

    $selected = @()
    $selectedFunctions = @()
    
    foreach ($c in @($chkTemp,$chkDisk,$chkOptimize,$chkSFC,$chkUpdate,$chkCache,$chkBrowser,$chkLogs)) {
        if ($c.Checked) { 
            $selected += $c.Text
            
            # Map to function names
            switch -Wildcard ($c.Text) {
                "*Temp*"     { $selectedFunctions += @{Name = "Clean-Temp"; Display = "Temp Files"} }
                "*Disk*"     { $selectedFunctions += @{Name = "Run-DiskCleanup"; Display = "Disk Cleanup"} }
                "*Optimize*" { $selectedFunctions += @{Name = "Optimize-Drives"; Display = "Drive Optimization"} }
                "*SFC*"      { $selectedFunctions += @{Name = "Run-SFC"; Display = "SFC/DISM"} }
                "*Update*"   { $selectedFunctions += @{Name = "Run-Update"; Display = "Windows Updates"} }
                "*Cache*"    { $selectedFunctions += @{Name = "Clear-UpdateCache"; Display = "Update Cache"} }
                "*Browser*"  { $selectedFunctions += @{Name = "Clear-BrowserCache"; Display = "Browser Cache"} }
                "*Logs*"     { $selectedFunctions += @{Name = "Cleanup-Logs"; Display = "Old Logs"} }
            }
        }
    }

    if ($selected.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Select at least one task.","No Selection",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Warning)
        # Re-enable controls
        $btnRun.Enabled = $true
        $btnSelectAll.Enabled = $true
        $btnDeselectAll.Enabled = $true
        foreach ($c in @($chkTemp,$chkDisk,$chkOptimize,$chkSFC,$chkUpdate,$chkCache,$chkBrowser,$chkLogs)) {
            $c.Enabled = $true
        }
        return
    }

    Write-UI "Selected $($selected.Count) task(s) to run." "Blue"
    Write-UI "" "Black"
    
    $steps = 0
    $successCount = 0
    $failCount = 0
    
    foreach ($func in $selectedFunctions) {
        if ($script:cancellationRequested) {
            Write-UI "=== Maintenance Cancelled ===" "Orange"
            break
        }
        
        $steps++
        $progressPercent = [int](($steps / $selectedFunctions.Count) * 100)
        Update-Progress $progressPercent "Running: $($func.Display) ($steps/$($selectedFunctions.Count))"
        
        try {
            $result = & $func.Name
            if ($result) {
                $successCount++
            } else {
                $failCount++
            }
        } catch {
            Write-UI "Error executing $($func.Display): $($_.Exception.Message)" "Red"
            Write-Log "Error executing $($func.Name): $($_.Exception.Message)" "ERROR"
            $failCount++
        }
        
        Write-UI "" "Black"
    }

    # Re-enable controls
    $btnRun.Enabled = $true
    $btnSelectAll.Enabled = $true
    $btnDeselectAll.Enabled = $true
    $btnCancel.Enabled = $false
    
    foreach ($c in @($chkTemp,$chkDisk,$chkOptimize,$chkSFC,$chkUpdate,$chkCache,$chkBrowser,$chkLogs)) {
        $c.Enabled = $true
    }

    if ($script:cancellationRequested) {
        Update-Progress 0 "Cancelled."
        Write-UI "=== Maintenance Cancelled ===" "Orange"
        [System.Windows.Forms.MessageBox]::Show(
            "Maintenance was cancelled. Some tasks may not have completed.",
            "Cancelled",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        )
    } else {
        Update-Progress 100 "All tasks completed."
        Write-UI "=== Maintenance Completed ===" "Green"
        Write-UI "Summary: $successCount succeeded, $failCount failed" "Blue"
        Write-UI "Total space freed: $(Format-Size ($script:totalSpaceFreed * 1MB))" "Green"
        
        $summary = "Maintenance completed!`n`n"
        $summary += "Tasks completed: $successCount`n"
        if ($failCount -gt 0) { $summary += "Tasks failed: $failCount`n" }
        $summary += "Total space freed: $(Format-Size ($script:totalSpaceFreed * 1MB))`n`n"
        $summary += "Check the log file for details: $logFile"
        
        [System.Windows.Forms.MessageBox]::Show(
            $summary,
            "Maintenance Complete",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        )
    }
    
    Write-Log "=== Maintenance Session Ended ===" "INFO"
    Write-Log "Summary: $successCount succeeded, $failCount failed" "INFO"
    Write-Log "Total space freed: $(Format-Size ($script:totalSpaceFreed * 1MB))" "INFO"
})

$btnExit.Add_Click({ 
    if ($btnCancel.Enabled) {
        $result = [System.Windows.Forms.MessageBox]::Show(
            "Maintenance is in progress. Do you want to cancel and exit?",
            "Exit Confirmation",
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Question
        )
        if ($result -eq "Yes") {
            $script:cancellationRequested = $true
            Start-Sleep -Seconds 1
        } else {
            return
        }
    }
    $form.Close() 
})

# =====================================
# Show Form
# =====================================
[void]$form.ShowDialog()
Stop-Transcript
