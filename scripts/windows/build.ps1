#!/usr/bin/env pwsh
# Build script for Multi-Client TCP Chat Server
# Compiles both server and client executables

param(
    [string]$Compiler = "g++",
    [string]$BuildType = "Release",
    [switch]$Clean,
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

# Function to check if command exists
function Test-Command {
    param([string]$Command)
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

# Function to clean build artifacts
function Remove-BuildArtifacts {
    Write-ColorOutput "Cleaning build artifacts..." $Blue
    
    $artifacts = @("*.exe", "*.o", "*.obj", "*.dll", "*.so", "*.dylib")
    foreach ($pattern in $artifacts) {
        Get-ChildItem -Path "build" -Filter $pattern -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force
    }
    
    Write-ColorOutput "Build artifacts cleaned." $Green
}

# Main build function
function Build-Project {
    param([string]$Compiler, [string]$BuildType, [bool]$Verbose)
    
    Write-ColorOutput "Building Multi-Client TCP Chat Server..." $Blue
    Write-ColorOutput "Compiler: $Compiler" $Yellow
    Write-ColorOutput "Build Type: $BuildType" $Yellow
    
    # Check if compiler exists
    if (-not (Test-Command $Compiler)) {
        Write-ColorOutput "Error: Compiler '$Compiler' not found. Please install MinGW-w64 or update your PATH." $Red
        Write-ColorOutput "Installation guide: https://www.msys2.org/" $Yellow
        exit 1
    }
    
    # Set compiler flags based on build type
    $commonFlags = "-std=c++11 -Wall -Wextra"
    $linkFlags = "-lws2_32"
    
    if ($BuildType -eq "Debug") {
        $commonFlags += " -g -O0 -DDEBUG"
    } else {
        $commonFlags += " -O2 -DNDEBUG"
    }
    
    if ($Verbose) {
        $commonFlags += " -v"
    }
    
    # Change to src directory
    Push-Location "src"
    
    try {
        # Build server
        Write-ColorOutput "Compiling server..." $Blue
        $serverCmd = "$Compiler $commonFlags -o ../build/server.exe server.cpp $linkFlags"
        
        if ($Verbose) {
            Write-ColorOutput "Command: $serverCmd" $Yellow
        }
        
        $serverResult = Invoke-Expression $serverCmd 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "✓ Server compiled successfully" $Green
        } else {
            Write-ColorOutput "✗ Server compilation failed:" $Red
            Write-ColorOutput $serverResult $Red
            exit 1
        }
        
        # Build client
        Write-ColorOutput "Compiling client..." $Blue
        $clientCmd = "$Compiler $commonFlags -o ../build/client.exe client.cpp $linkFlags"
        
        if ($Verbose) {
            Write-ColorOutput "Command: $clientCmd" $Yellow
        }
        
        $clientResult = Invoke-Expression $clientCmd 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "✓ Client compiled successfully" $Green
        } else {
            Write-ColorOutput "✗ Client compilation failed:" $Red
            Write-ColorOutput $clientResult $Red
            exit 1
        }
        
        # Show build results
        Write-ColorOutput "`nBuild completed successfully!" $Green
        Write-ColorOutput "Generated files:" $Blue
        Get-ChildItem -Path "../build" -Name "*.exe" | ForEach-Object { Write-ColorOutput "  - $_" $Yellow }
        
    }
    finally {
        Pop-Location
    }
}

# Main execution
if ($Clean) {
    Remove-BuildArtifacts
}

Build-Project -Compiler $Compiler -BuildType $BuildType -Verbose $Verbose
