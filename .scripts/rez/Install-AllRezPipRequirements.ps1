<#
.SYNOPSIS
    Installs all packages from `requirements.rezpip.txt` for all Python versions.

.PARAMETER Release
    If specified, installs to the release path instead of local.

.PARAMETER RequirementsFile
    Path to the requirements file. Defaults to `requirements.rezpip.txt` in the repo root.

.EXAMPLE
    .\Install-AllRezPipRequirements.ps1
    .\Install-AllRezPipRequirements.ps1 -Release
#>

param(
    [switch]$Release,

    [string]$RequirementsFile = "$PSScriptRoot\..\..\requirements.rezpip.txt"
)

# Get Python versions dynamically from Rez
$PythonPackages = rez-search python --format "{qualified_name}" 2>$null
if (-not $PythonPackages) {
    Write-Host "ERROR: Could not retrieve Python versions from Rez." -ForegroundColor Red
    exit 1
}

# Extract version numbers (e.g., "python-3.11.9" -> "3.11.9", "python-3.10.13.deadline" -> "3.10.13")
$PythonVersions = $PythonPackages | ForEach-Object {
    if ($_ -match '^python-(\d+\.\d+\.\d+)') {
        $Matches[1]
    }
} | Sort-Object -Unique

if ($PythonVersions.Count -eq 0) {
    Write-Host "ERROR: No valid Python versions found in Rez." -ForegroundColor Red
    exit 1
}

Write-Host "Found Python versions: $($PythonVersions -join ', ')" -ForegroundColor Green

# Resolve the requirements file path
$RequirementsFile = Resolve-Path $RequirementsFile -ErrorAction Stop

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Installing all requirements from:" -ForegroundColor Cyan
Write-Host "$RequirementsFile" -ForegroundColor White
Write-Host "========================================`n" -ForegroundColor Cyan

# Read and parse requirements (skip comments and empty lines, skip 'python' as it's the interpreter)
$packages = Get-Content $RequirementsFile |
    Where-Object { $_ -match '\S' -and $_ -notmatch '^\s*#' -and $_ -notmatch '^\s*python\s*$' } |
    ForEach-Object { $_.Trim() }

if ($packages.Count -eq 0) {
    Write-Host "No packages found in requirements file." -ForegroundColor Yellow
    exit 0
}

Write-Host "Packages to install:" -ForegroundColor Yellow
$packages | ForEach-Object { Write-Host "  - $_" -ForegroundColor White }
Write-Host ""

$ReleaseFlag = if ($Release) { "--release" } else { "" }
$failedInstalls = @()

foreach ($version in $PythonVersions) {
    Write-Host "`n========================================" -ForegroundColor Yellow
    Write-Host "Python $version" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow

    foreach ($package in $packages) {
        Write-Host "`n  Installing: $package" -ForegroundColor Cyan

        $cmd = "rez pip --python-version $version --install $ReleaseFlag `"$package`" --verbose"
        Write-Host "  Running: $cmd" -ForegroundColor DarkGray

        Invoke-Expression $cmd

        if ($LASTEXITCODE -ne 0) {
            Write-Host "  WARNING: Failed to install $package for Python $version" -ForegroundColor Red
            $failedInstalls += "$package (Python $version)"
        } else {
            Write-Host "  SUCCESS: $package" -ForegroundColor Green
        }
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if ($failedInstalls.Count -gt 0) {
    Write-Host "`nFailed installations:" -ForegroundColor Red
    $failedInstalls | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
} else {
    Write-Host "`nAll packages installed successfully!" -ForegroundColor Green
}

Write-Host ""
