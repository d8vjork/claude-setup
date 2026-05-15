# Claude Code setup installer for Windows
# Run with: powershell -ExecutionPolicy Bypass -File install.ps1
#
# Requires PowerShell 5.1+ (built into Windows 10/11)

$ErrorActionPreference = "Stop"

$ScriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$ClaudeDir  = Join-Path $env:USERPROFILE ".claude"

Write-Host ""
Write-Host "Claude Setup Installer"
Write-Host "======================"
Write-Host ""
Write-Host "What would you like to install?"
Write-Host ""
Write-Host "  1) Statusline only"
Write-Host "  2) Full settings (plugins, model, etc.) + statusline"
Write-Host "  3) Full settings only (no statusline)"
Write-Host ""
$choice = Read-Host "Enter choice [2]"
if (-not $choice) { $choice = "2" }

switch ($choice) {
    "1" { $installStatusline = $true;  $installSettings = $false }
    "2" { $installStatusline = $true;  $installSettings = $true  }
    "3" { $installStatusline = $false; $installSettings = $true  }
    default { Write-Host "Invalid choice. Exiting."; exit 1 }
}

if (-not (Test-Path $ClaudeDir)) {
    New-Item -ItemType Directory -Path $ClaudeDir | Out-Null
}

if ($installStatusline) {
    Copy-Item (Join-Path $ScriptDir "statusline.ps1") (Join-Path $ClaudeDir "statusline.ps1") -Force
    Write-Host "Installed statusline.ps1 -> $ClaudeDir\statusline.ps1"
}

$statusLineBlock = [PSCustomObject]@{
    type    = "command"
    command = "powershell -NoProfile -NonInteractive -File ~/.claude/statusline.ps1"
    padding = 2
}

$settingsPath = Join-Path $ClaudeDir "settings.json"

if ($installSettings) {
    if (Test-Path $settingsPath) {
        Write-Host "Backing up existing settings.json -> settings.json.bak"
        Copy-Item $settingsPath (Join-Path $ClaudeDir "settings.json.bak") -Force
    }

    $settings = Get-Content (Join-Path $ScriptDir "settings.json") -Raw | ConvertFrom-Json

    if ($installStatusline) {
        $settings.statusLine.command = $statusLineBlock.command
    } else {
        # Remove statusLine since the script won't be installed
        $settings.PSObject.Properties.Remove("statusLine")
    }

    $settings | ConvertTo-Json -Depth 10 | Set-Content $settingsPath -Encoding UTF8
    Write-Host "Installed settings.json -> $settingsPath"

    # Install user-level CLAUDE.md (git rules + orchestrated-feature pointer)
    $claudeMdPath = Join-Path $ClaudeDir "CLAUDE.md"
    if (Test-Path $claudeMdPath) {
        Write-Host "Backing up existing CLAUDE.md -> CLAUDE.md.bak"
        Copy-Item $claudeMdPath (Join-Path $ClaudeDir "CLAUDE.md.bak") -Force
    }
    Copy-Item (Join-Path $ScriptDir "CLAUDE.md") $claudeMdPath -Force
    Write-Host "Installed CLAUDE.md -> $claudeMdPath"
}

if (-not $installSettings -and $installStatusline) {
    # Statusline only — add/update just the statusLine key in settings.json
    if (Test-Path $settingsPath) {
        $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json
        if ($settings.PSObject.Properties["statusLine"]) {
            $settings.statusLine = $statusLineBlock
        } else {
            $settings | Add-Member -MemberType NoteProperty -Name "statusLine" -Value $statusLineBlock
        }
        $settings | ConvertTo-Json -Depth 10 | Set-Content $settingsPath -Encoding UTF8
        Write-Host "Updated statusLine in existing settings.json"
    } else {
        [PSCustomObject]@{ statusLine = $statusLineBlock } |
            ConvertTo-Json -Depth 10 |
            Set-Content $settingsPath -Encoding UTF8
        Write-Host "Created settings.json with statusLine"
    }
}

Write-Host ""
Write-Host "Done. Claude settings installed to $ClaudeDir"
