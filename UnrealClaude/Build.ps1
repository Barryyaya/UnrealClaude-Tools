# UnrealClaude Build Script
# Auto-detects Unreal Engine version and builds the plugin
# Usage: .\Build.ps1 [-Version <5.6|5.7>] [-Platform <Win64|Linux|Mac>]
# Example: .\Build.ps1 -Version 5.7 -Platform Win64

param(
    [Parameter(Position=0)]
    [string]$Version = "",

    [Parameter(Position=1)]
    [ValidateSet("Win64", "Linux", "Mac")]
    [string]$Platform = "Win64",

    [switch]$Clean,
    [switch]$Help
)

$ErrorActionPreference = "Stop"

# Colors for output
function Write-Success($Message) { Write-Host "[SUCCESS] $Message" -ForegroundColor Green }
function Write-Info($Message) { Write-Host "[INFO] $Message" -ForegroundColor Cyan }
function Write-Warn($Message) { Write-Host "[WARNING] $Message" -ForegroundColor Yellow }
function Write-Fail($Message) { Write-Host "[ERROR] $Message" -ForegroundColor Red }

# Show help
if ($Help) {
    Write-Host @"

UnrealClaude Build Script
====================

Usage:
  .\Build.ps1 [-Version <5.6|5.7>] [-Platform <Win64|Linux|Mac>] [-Clean]

Parameters:
  -Version  UE version (5.6 or 5.7). Auto-detected if omitted.
  -Platform Target platform (Win64, Linux, or Mac)
  -Clean    Clean build directory before building
  -Help     Show this help message

Examples:
  .\Build.ps1                    # Auto-detect UE and build
  .\Build.ps1 -Version 5.7    # Build for UE 5.7
  .\Build.ps1 -Clean          # Clean and rebuild

"@
    exit 0
}

# Get script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = $ScriptDir
$PluginName = "UnrealClaude"
$UPluginFile = Join-Path $ProjectRoot "$PluginName\$PluginName.uplugin"

# Check if plugin file exists
if (-not (Test-Path $UPluginFile)) {
    Write-Fail "Plugin file not found: $UPluginFile"
    exit 1
}

# Read plugin to get current target version
$PluginJson = Get-Content $UPluginFile -Raw | ConvertFrom-Json
$CurrentVersion = $PluginJson.EngineVersion

Write-Info "Current plugin target: UE $CurrentVersion"

# Auto-detect UE version if not specified
if ($Version -eq "") {
    Write-Info "Detecting UE installation..."

    # Common UE installation paths
    $UESearchPaths = @(
        "C:\UE_5.7",
        "C:\UE_5.6",
        "D:\UE_5.7",
        "D:\UE_5.6",
        "$env:PROGRAMFILES\Epic Games\UE_5.7",
        "$env:PROGRAMFILES\Epic Games\UE_5.6"
    )

    foreach ($Path in $UESearchPaths) {
        if (Test-Path $Path) {
            $Version = $Path -replace '.*UE_(\d+\.\d+).*', '$1'
            Write-Info "Found UE installation: $Path (version $Version)"
            break
        }
    }

    if ($Version -eq "") {
        Write-Fail "Could not auto-detect UE installation"
        Write-Host "Please specify version manually: .\Build.ps1 -Version 5.7"
        exit 1
    }
}

# Validate version
if ($Version -ne "5.6" -and $Version -ne "5.7") {
    Write-Fail "Invalid version: $Version. Use 5.6 or 5.7"
    exit 1
}

# Set UE path
$UEPath = "C:\UE_$Version"
if (-not (Test-Path $UEPath)) {
    $UEPath = "D:\UE_$Version"
    if (-not (Test-Path $UEPath)) {
        Write-Fail "UE $Version not found at $UEPath"
        exit 1
    }
}

Write-Success "Using UE $Version at: $UEPath"

# Build output directory
$OutputDir = Join-Path $ProjectRoot "build\UE$Version.Replace('.', '')"
if ($Clean -and (Test-Path $OutputDir)) {
    Write-Info "Cleaning build directory..."
    Remove-Item $OutputDir -Recurse -Force
}

# Create build command
$BuildScript = Join-Path $UEPath "Engine\Build\BatchFiles\RunUAT.bat"
if ($Platform -eq "Linux") { $BuildScript = Join-Path $UEPath "Engine/Build/BatchFiles/RunUAT.sh" }
if ($Platform -eq "Mac") { $BuildScript = Join-Path $UEPath "Engine/Build/BatchFiles/RunUAT.sh" }

if (-not (Test-Path $BuildScript)) {
    Write-Fail "Build script not found: $BuildScript"
    exit 1
}

# Build command
$TargetPlatformArg = if ($Platform -eq "Win64") { "Win64" } else { $Platform }
$PackageDir = "$ProjectRoot\build\UE$Version.Replace('.', '')"

Write-Host ""
Write-Info "Starting build for UE $Version ($Platform)..."
Write-Info "Output: $PackageDir"
Write-Host ""

try {
    if ($Platform -eq "Win64") {
        & $BuildScript BuildPlugin -Plugin="$UPluginFile" -Package="$PackageDir" -TargetPlatforms=$TargetPlatformArg
    } else {
        & $BuildScript BuildPlugin -Plugin="$UPluginFile" -Package="$PackageDir" -TargetPlatforms=$TargetPlatformArg
    }

    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Success "Build completed successfully!"
        Write-Info "Output directory: $PackageDir"

        # Show output structure
        if (Test-Path $PackageDir) {
            Write-Host ""
            Write-Info "Build output:"
            Get-ChildItem $PackageDir | ForEach-Object {
                Write-Host "  $($_.Name)/"
            }
        }
    } else {
        Write-Fail "Build failed with exit code: $LASTEXITCODE"
        exit $LASTEXITCODE
    }
} catch {
    Write-Fail "Build failed: $_"
    exit 1
}