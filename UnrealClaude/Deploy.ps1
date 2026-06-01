# UnrealClaude Deploy Script
# Deploys built plugin to project or engine marketplace
# Usage: .\Deploy.ps1 [-Target <Project|Engine>] [-ProjectPath <path>]
# Example: .\Deploy.ps1 -Target Project -ProjectPath "C:\MyProject"

param(
    [Parameter(Position=0)]
    [ValidateSet("Project", "Engine")]
    [string]$Target = "Engine",

    [Parameter(Position=1)]
    [string]$ProjectPath = "",

    [switch]$Help
)

$ErrorActionPreference = "Stop"

# Colors
function Write-Success($Message) { Write-Host "[SUCCESS] $Message" -ForegroundColor Green }
function Write-Info($Message) { Write-Host "[INFO] $Message" -ForegroundColor Cyan }
function Write-Warn($Message) { Write-Host "[WARNING] $Message" -ForegroundColor Yellow }
function Write-Fail($Message) { Write-Host "[ERROR] $Message" -ForegroundColor Red }

# Help
if ($Help) {
    Write-Host @"

UnrealClaude Deploy Script
=========================

Usage:
  .\Deploy.ps1 [-Target <Project|Engine>] [-ProjectPath <path>]

Parameters:
  -Target       Deploy target: Project or Engine
  -ProjectPath  Path to Unreal project (required for Project target)
  -Help         Show this help message

Examples:
  .\Deploy.ps1                              # Deploy to engine
  .\Deploy.ps1 -Target Project           # Deploy to project plugins folder
  .\Deploy.ps1 -Target Project -ProjectPath "C:\MyGame"

Notes:
  - Project target: Copies to YourProject/Plugins/UnrealClaude/
  - Engine target: Copies to UE_Version/Engine/Plugins/Marketplace/

"@
    exit 0
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$BuildDir = Join-Path $ScriptDir "build"

# Find latest build
$BuildVersions = @("UE57", "UE56")
$SelectedBuild = ""

foreach ($Ver in $BuildVersions) {
    $Path = Join-Path $BuildDir $Ver
    if (Test-Path $Path) {
        $SelectedBuild = $Ver
        break
    }
}

if ($SelectedBuild -eq "") {
    Write-Fail "No built plugin found. Run Build.ps1 first."
    exit 1
}

$SourcePath = Join-Path $BuildDir $SelectedBuild
Write-Info "Using build: $SelectedBuild"

# Detect UE version from build folder
$Version = if ($SelectedBuild -eq "UE57") { "5.7" } else { "5.6" }

# Determine target path
if ($Target -eq "Engine") {
    $InstallPath = "C:\UE_$Version\Engine\Plugins\Marketplace\UnrealClaude"
    if (-not (Test-Path "C:\UE_$Version")) {
        $InstallPath = "D:\UE_$Version\Engine\Plugins\Marketplace\UnrealClaude"
    }
} elseif ($ProjectPath -eq "") {
    Write-Fail "ProjectPath is required for Project deployment"
    Write-Host "Example: .\Deploy.ps1 -Target Project -ProjectPath `"C:\MyGame`""
    exit 1
} else {
    $InstallPath = Join-Path $ProjectPath "Plugins\UnrealClaude"
}

Write-Info "Target: $Target"
Write-Info "Installing to: $InstallPath"

# Check source exists
if (-not (Test-Path $SourcePath)) {
    Write-Fail "Build not found: $SourcePath"
    exit 1
}

# Confirm before deploying
Write-Host ""
$Confirm = Read-Host "Deploy to $InstallPath? (y/n)"
if ($Confirm -ne "y" -and $Confirm -ne "Y") {
    Write-Info "Deployment cancelled"
    exit 0
}

# Create target directory
$TargetDir = Split-Path $InstallPath
if (-not (Test-Path $TargetDir)) {
    Write-Info "Creating directory: $TargetDir"
    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
}

# Deploy
try {
    Write-Info "Copying files..."
    Copy-Item -Path "$SourcePath\*" -Destination $InstallPath -Recurse -Force

    # Install MCP bridge dependencies
    $MCPBridge = Join-Path $InstallPath "Resources\mcp-bridge"
    if (Test-Path $MCPBridge) {
        Write-Info "Installing MCP bridge dependencies..."
        Set-Location $MCPBridge
        npm install 2>$null
        Set-Location $ScriptDir
    }

    Write-Host ""
    Write-Success "Deployment completed!"
    Write-Host ""
    Write-Host "Next steps:"
    Write-Host "  1. Launch Unreal Editor"
    Write-Host "  2. The plugin will load automatically"
    Write-Host "  3. Access via Tools > Claude Assistant"
    Write-Host ""
} catch {
    Write-Fail "Deployment failed: $_"
    exit 1
}