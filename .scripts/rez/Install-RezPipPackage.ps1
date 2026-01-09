<#
.SYNOPSIS
    Installs a Python package via rez-pip for all available Python versions.

.PARAMETER PackageName
    The name of the pip package to install.

.PARAMETER Release
    If specified, installs to the release path instead of local.

.EXAMPLE
    .\Install-RezPipPackage.ps1 requests
    .\Install-RezPipPackage.ps1 requests -Release
    .\Install-RezPipPackage.ps1 "requests>=2.28.0" -Release
#>

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$PackageName,

    [switch]$Release
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

$ReleaseFlag = if ($Release) { "--release" } else { "" }

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Installing '$PackageName' for all Python versions" -ForegroundColor Cyan
Write-Host "Found: $($PythonVersions -join ', ')" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan

foreach ($version in $PythonVersions) {
    Write-Host "`n----------------------------------------" -ForegroundColor Yellow
    Write-Host "Python $version" -ForegroundColor Yellow
    Write-Host "----------------------------------------" -ForegroundColor Yellow

    $cmd = "rez pip --python-version $version --install $ReleaseFlag `"$PackageName`" --verbose"
    Write-Host "Running: $cmd" -ForegroundColor DarkGray

    Invoke-Expression $cmd

    if ($LASTEXITCODE -ne 0) {
        Write-Host "WARNING: Failed to install for Python $version" -ForegroundColor Red
    } else {
        Write-Host "SUCCESS: Installed for Python $version" -ForegroundColor Green
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Done!" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan
