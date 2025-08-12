#!/usr/bin/env pwsh
# Clean script for Multi-Client TCP Chat Server
# Removes build artifacts, temporary files, and cleans up the project

param(
    [switch]$All,
    [switch]$Build,
    [switch]$Temp,
    [switch]$Logs,
    [switch]$Force,
    [switch]$Verbose
)

# Colors for output
$Red = "`e[31m"
$Green = "`e[32m"
$Yellow = "`e[33m"
$Blue = "`e[34m"
$Reset = "`e[0m"

# Function to print colored output
function Write-ColorOutput {
    param([string]$Message, [string]$Color = $Reset)
    Write-Host "$Color$Message$Reset"
}

# Function to safely remove files
function Remove-FilesSafely {
    param([string]$Pattern, [string]$Description, [bool]$Force)
    
    Write-ColorOutput "Cleaning $Description..." $Blue
    
    $files = Get-ChildItem -Path "." -Filter $Pattern -Recurse -ErrorAction SilentlyContinue
    
    if ($files.Count -eq 0) {
        Write-ColorOutput "  No $Description found" $Yellow
        return 0
    }
    
    $removedCount = 0
    
    foreach ($file in $files) {
        try {
            if ($Verbose) {
                Write-ColorOutput "  Removing: $($file.FullName)" $Yellow
            }
            
            Remove-Item -Path $file.FullName -Force:$Force -ErrorAction Stop
            $removedCount++
        }
        catch {
            Write-ColorOutput "  Failed to remove: $($file.FullName)" $Red
        }
    }
    
    Write-ColorOutput "  Removed $removedCount $Description" $Green
    return $removedCount
}

# Function to clean build artifacts
function Remove-BuildArtifacts {
    Write-ColorOutput "`n=== Cleaning Build Artifacts ===" $Blue
    
    $buildPatterns = @(
        @{ Pattern = "*.exe"; Description = "executables" },
        @{ Pattern = "*.o"; Description = "object files" },
        @{ Pattern = "*.obj"; Description = "object files" },
        @{ Pattern = "*.dll"; Description = "dynamic libraries" },
        @{ Pattern = "*.so"; Description = "shared objects" },
        @{ Pattern = "*.dylib"; Description = "dynamic libraries" },
        @{ Pattern = "*.a"; Description = "static libraries" },
        @{ Pattern = "*.lib"; Description = "library files" },
        @{ Pattern = "*.pdb"; Description = "debug files" },
        @{ Pattern = "*.ilk"; Description = "incremental link files" },
        @{ Pattern = "*.exp"; Description = "export files" },
        @{ Pattern = "*.map"; Description = "map files" }
    )
    
    $totalRemoved = 0
    
    foreach ($pattern in $buildPatterns) {
        $removed = Remove-FilesSafely -Pattern $pattern.Pattern -Description $pattern.Description -Force $Force
        $totalRemoved += $removed
    }
    
    Write-ColorOutput "`nTotal build artifacts removed: $totalRemoved" $Green
}

# Function to clean temporary files
function Remove-TempFiles {
    Write-ColorOutput "`n=== Cleaning Temporary Files ===" $Blue
    
    $tempPatterns = @(
        @{ Pattern = "*.tmp"; Description = "temporary files" },
        @{ Pattern = "*.temp"; Description = "temporary files" },
        @{ Pattern = "*.bak"; Description = "backup files" },
        @{ Pattern = "*.swp"; Description = "swap files" },
        @{ Pattern = "*.swo"; Description = "swap files" },
        @{ Pattern = "*~"; Description = "backup files" },
        @{ Pattern = ".DS_Store"; Description = "macOS files" },
        @{ Pattern = "Thumbs.db"; Description = "Windows thumbnail files" }
    )
    
    $totalRemoved = 0
    
    foreach ($pattern in $tempPatterns) {
        $removed = Remove-FilesSafely -Pattern $pattern.Pattern -Description $pattern.Description -Force $Force
        $totalRemoved += $removed
    }
    
    Write-ColorOutput "`nTotal temporary files removed: $totalRemoved" $Green
}

# Function to clean log files
function Remove-LogFiles {
    Write-ColorOutput "`n=== Cleaning Log Files ===" $Blue
    
    $logPatterns = @(
        @{ Pattern = "*.log"; Description = "log files" },
        @{ Pattern = "*.out"; Description = "output files" },
        @{ Pattern = "*.err"; Description = "error files" }
    )
    
    $totalRemoved = 0
    
    foreach ($pattern in $logPatterns) {
        $removed = Remove-FilesSafely -Pattern $pattern.Pattern -Description $pattern.Description -Force $Force
        $totalRemoved += $removed
    }
    
    Write-ColorOutput "`nTotal log files removed: $totalRemoved" $Green
}

# Function to clean empty directories
function Remove-EmptyDirectories {
    Write-ColorOutput "`n=== Cleaning Empty Directories ===" $Blue
    
    $emptyDirs = Get-ChildItem -Path "." -Directory -Recurse -ErrorAction SilentlyContinue | 
                 Where-Object { (Get-ChildItem -Path $_.FullName -Force -ErrorAction SilentlyContinue).Count -eq 0 }
    
    if ($emptyDirs.Count -eq 0) {
        Write-ColorOutput "  No empty directories found" $Yellow
        return 0
    }
    
    $removedCount = 0
    
    foreach ($dir in $emptyDirs) {
        try {
            if ($Verbose) {
                Write-ColorOutput "  Removing empty directory: $($dir.FullName)" $Yellow
            }
            
            Remove-Item -Path $dir.FullName -Force:$Force -ErrorAction Stop
            $removedCount++
        }
        catch {
            Write-ColorOutput "  Failed to remove directory: $($dir.FullName)" $Red
        }
    }
    
    Write-ColorOutput "  Removed $removedCount empty directories" $Green
    return $removedCount
}

# Function to show disk usage
function Show-DiskUsage {
    Write-ColorOutput "`n=== Current Disk Usage ===" $Blue
    
    $currentDir = Get-Location
    $size = (Get-ChildItem -Path $currentDir -Recurse -ErrorAction SilentlyContinue | 
             Measure-Object -Property Length -Sum).Sum
    
    if ($size) {
        $sizeMB = [math]::Round($size / 1MB, 2)
        Write-ColorOutput "Project size: $sizeMB MB" $Yellow
    } else {
        Write-ColorOutput "Project size: 0 MB" $Yellow
    }
}

# Function to clean all
function Remove-All {
    Write-ColorOutput "`n=== Full Clean ===" $Blue
    
    Remove-BuildArtifacts
    Remove-TempFiles
    Remove-LogFiles
    Remove-EmptyDirectories
    
    Write-ColorOutput "`n✅ Full clean completed!" $Green
}

# Main execution
Write-ColorOutput "Multi-Client TCP Chat Server - Clean Script" $Blue

# Show current disk usage
Show-DiskUsage

# Determine what to clean
if ($All) {
    Remove-All
} elseif ($Build) {
    Remove-BuildArtifacts
} elseif ($Temp) {
    Remove-TempFiles
} elseif ($Logs) {
    Remove-LogFiles
} else {
    # Default: clean build artifacts only
    Write-ColorOutput "`nNo specific target specified. Cleaning build artifacts..." $Yellow
    Remove-BuildArtifacts
}

# Show final disk usage
Show-DiskUsage

Write-ColorOutput "`nClean operation completed!" $Green
