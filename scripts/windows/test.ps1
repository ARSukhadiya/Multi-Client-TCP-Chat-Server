#!/usr/bin/env pwsh
# Simple test script for Multi-Client TCP Chat Server

param(
    [int]$Port = 8080,
    [string]$ServerIP = "127.0.0.1",
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

# Function to check if port is available
function Test-PortAvailable {
    param([int]$Port)
    try {
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $tcpClient.Connect("127.0.0.1", $Port)
        $tcpClient.Close()
        return $false
    }
    catch {
        return $true
    }
}

# Function to run basic connectivity test
function Test-BasicConnectivity {
    param([string]$ServerIP, [int]$Port)
    
    Write-ColorOutput "Testing Basic Connectivity" $Blue
    
    try {
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $tcpClient.Connect($ServerIP, $Port)
        $tcpClient.Close()
        
        Write-ColorOutput "Server is reachable" $Green
        return $true
    }
    catch {
        Write-ColorOutput "Cannot connect to server" $Red
        return $false
    }
}

# Main execution
Write-ColorOutput "Starting Multi-Client TCP Chat Server Tests" $Blue

# Check if executables exist
$serverExe = "build\server.exe"
$clientExe = "build\client.exe"

if (-not (Test-Path $serverExe)) {
    Write-ColorOutput "Error: Server executable not found. Run build.ps1 first." $Red
    exit 1
}

if (-not (Test-Path $clientExe)) {
    Write-ColorOutput "Error: Client executable not found. Run build.ps1 first." $Red
    exit 1
}

# Check if port is available
if (-not (Test-PortAvailable $Port)) {
    Write-ColorOutput "Warning: Port $Port is already in use" $Yellow
    exit 1
}

# Start server in background
Write-ColorOutput "Starting server..." $Blue
$serverJob = Start-Job -ScriptBlock {
    param($ServerExe, $Port)
    Set-Location $PSScriptRoot
    & $ServerExe $Port
} -ArgumentList $serverExe, $Port

# Wait a moment for server to start
Start-Sleep -Seconds 2

# Run basic connectivity test
$testResult = Test-BasicConnectivity -ServerIP $ServerIP -Port $Port

if ($testResult) {
    Write-ColorOutput "All tests completed successfully!" $Green
    exit 0
} else {
    Write-ColorOutput "Some tests failed" $Red
    exit 1
}
finally {
    # Cleanup
    Stop-Job $serverJob
    Remove-Job $serverJob
}
