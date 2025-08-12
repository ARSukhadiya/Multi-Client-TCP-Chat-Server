#!/usr/bin/env pwsh
# Run script for Multi-Client TCP Chat Server
# Provides easy commands to start server and clients

param(
    [string]$Mode = "help",
    [int]$Port = 8080,
    [string]$ServerIP = "127.0.0.1",
    [int]$NumClients = 1,
    [switch]$Background,
    [switch]$Verbose
)

# Colors for output
$Red = "`e[31m"
$Green = "`e[32m"
$Yellow = "`e[33m"
$Blue = "`e[34m"
$Cyan = "`e[36m"
$Reset = "`e[0m"

# Function to print colored output
function Write-ColorOutput {
    param([string]$Message, [string]$Color = $Reset)
    Write-Host "$Color$Message$Reset"
}

# Function to check if executable exists
function Test-Executable {
    param([string]$Path)
    return Test-Path $Path
}

# Function to show help
function Show-Help {
    Write-ColorOutput "Multi-Client TCP Chat Server - Run Script" $Blue
    Write-ColorOutput "==========================================" $Blue
    
    Write-ColorOutput "`nUsage:" $Yellow
    Write-ColorOutput "  .\run.ps1 [Mode] [Options]" $Cyan
    
    Write-ColorOutput "`nModes:" $Yellow
    Write-ColorOutput "  server [Port]     - Start the server on specified port (default: 8080)" $Cyan
    Write-ColorOutput "  client [IP] [Port] - Start a client connecting to server" $Cyan
    Write-ColorOutput "  demo [Port]       - Start server and multiple clients for demo" $Cyan
    Write-ColorOutput "  help              - Show this help message" $Cyan
    
    Write-ColorOutput "`nOptions:" $Yellow
    Write-ColorOutput "  -Port <number>    - Specify port number (default: 8080)" $Cyan
    Write-ColorOutput "  -ServerIP <ip>    - Specify server IP (default: 127.0.0.1)" $Cyan
    Write-ColorOutput "  -NumClients <n>   - Number of clients for demo mode (default: 2)" $Cyan
    Write-ColorOutput "  -Background       - Run processes in background" $Cyan
    Write-ColorOutput "  -Verbose          - Show detailed output" $Cyan
    
    Write-ColorOutput "`nExamples:" $Yellow
    Write-ColorOutput "  .\run.ps1 server 8080" $Cyan
    Write-ColorOutput "  .\run.ps1 client 127.0.0.1 8080" $Cyan
    Write-ColorOutput "  .\run.ps1 demo 8080 -NumClients 3" $Cyan
    Write-ColorOutput "  .\run.ps1 server -Background" $Cyan
    
    Write-ColorOutput "`nNote: Make sure to run build.ps1 first to compile the executables." $Yellow
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

# Function to start server
function Start-Server {
    param([int]$Port, [bool]$Background)
    
    Write-ColorOutput "Starting server on port $Port..." $Blue
    
    if (-not (Test-PortAvailable $Port)) {
        Write-ColorOutput "Error: Port $Port is already in use" $Red
        Write-ColorOutput "Please stop any existing server or choose a different port" $Yellow
        exit 1
    }
    
    $serverExe = "build\server.exe"
    
    if (-not (Test-Executable $serverExe)) {
        Write-ColorOutput "Error: Server executable not found. Run build.ps1 first." $Red
        exit 1
    }
    
    if ($Background) {
        Write-ColorOutput "Starting server in background..." $Yellow
        Start-Process -FilePath $serverExe -ArgumentList $Port -NoNewWindow
        Write-ColorOutput "Server started in background. Use 'Get-Process server' to check status." $Green
    } else {
        Write-ColorOutput "Starting server in foreground..." $Yellow
        Write-ColorOutput "Press Ctrl+C to stop the server" $Cyan
        & $serverExe $Port
    }
}

# Function to start client
function Start-Client {
    param([string]$ServerIP, [int]$Port, [bool]$Background)
    
    Write-ColorOutput "Starting client connecting to $ServerIP`:$Port..." $Blue
    
    $clientExe = "build\client.exe"
    
    if (-not (Test-Executable $clientExe)) {
        Write-ColorOutput "Error: Client executable not found. Run build.ps1 first." $Red
        exit 1
    }
    
    if ($Background) {
        Write-ColorOutput "Starting client in background..." $Yellow
        Start-Process -FilePath $clientExe -ArgumentList $ServerIP, $Port -NoNewWindow
        Write-ColorOutput "Client started in background." $Green
    } else {
        Write-ColorOutput "Starting client in foreground..." $Yellow
        Write-ColorOutput "Type your messages and press Enter to send" $Cyan
        Write-ColorOutput "Press Ctrl+C to disconnect" $Cyan
        & $clientExe $ServerIP $Port
    }
}

# Function to run demo
function Start-Demo {
    param([int]$Port, [int]$NumClients, [bool]$Background)
    
    Write-ColorOutput "Starting demo with server and $NumClients clients..." $Blue
    
    # Check if executables exist
    $serverExe = "build\server.exe"
    $clientExe = "build\client.exe"
    
    if (-not (Test-Executable $serverExe)) {
        Write-ColorOutput "Error: Server executable not found. Run build.ps1 first." $Red
        exit 1
    }
    
    if (-not (Test-Executable $clientExe)) {
        Write-ColorOutput "Error: Client executable not found. Run build.ps1 first." $Red
        exit 1
    }
    
    # Check if port is available
    if (-not (Test-PortAvailable $Port)) {
        Write-ColorOutput "Error: Port $Port is already in use" $Red
        Write-ColorOutput "Please stop any existing server or choose a different port" $Yellow
        exit 1
    }
    
    Write-ColorOutput "`n=== Demo Setup ===" $Blue
    Write-ColorOutput "Server will start on port $Port" $Yellow
    Write-ColorOutput "Clients will connect to 127.0.0.1:$Port" $Yellow
    Write-ColorOutput "Number of clients: $NumClients" $Yellow
    
    if ($Background) {
        Write-ColorOutput "`nStarting server in background..." $Blue
        Start-Process -FilePath $serverExe -ArgumentList $Port -NoNewWindow
        
        # Wait a moment for server to start
        Start-Sleep -Seconds 2
        
        Write-ColorOutput "Starting $NumClients clients in background..." $Blue
        for ($i = 1; $i -le $NumClients; $i++) {
            Start-Process -FilePath $clientExe -ArgumentList "127.0.0.1", $Port -NoNewWindow
            Start-Sleep -Milliseconds 500
        }
        
        Write-ColorOutput "`n✅ Demo started successfully!" $Green
        Write-ColorOutput "Server and $NumClients clients are running in background" $Yellow
        Write-ColorOutput "Use 'Get-Process server,client' to see running processes" $Cyan
        Write-ColorOutput "Use 'Stop-Process -Name server,client -Force' to stop all" $Cyan
        
    } else {
        Write-ColorOutput "`nThis will open multiple terminal windows." $Yellow
        Write-ColorOutput "Press any key to continue..." $Cyan
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        
        # Start server in new window
        Write-ColorOutput "Starting server..." $Blue
        Start-Process -FilePath "powershell" -ArgumentList "-Command", "cd '$PWD'; .\build\server.exe $Port"
        
        # Wait for server to start
        Start-Sleep -Seconds 2
        
        # Start clients in new windows
        for ($i = 1; $i -le $NumClients; $i++) {
            Write-ColorOutput "Starting client $i..." $Blue
            Start-Process -FilePath "powershell" -ArgumentList "-Command", "cd '$PWD'; .\build\client.exe 127.0.0.1 $Port"
            Start-Sleep -Milliseconds 500
        }
        
        Write-ColorOutput "`n✅ Demo started successfully!" $Green
        Write-ColorOutput "Server and $NumClients clients are running in separate windows" $Yellow
    }
}

# Function to show status
function Show-Status {
    Write-ColorOutput "=== Process Status ===" $Blue
    
    $serverProcesses = Get-Process -Name "server" -ErrorAction SilentlyContinue
    $clientProcesses = Get-Process -Name "client" -ErrorAction SilentlyContinue
    
    if ($serverProcesses) {
        Write-ColorOutput "Server processes: $($serverProcesses.Count)" $Green
        foreach ($proc in $serverProcesses) {
            Write-ColorOutput "  - PID: $($proc.Id), Started: $($proc.StartTime)" $Yellow
        }
    } else {
        Write-ColorOutput "No server processes running" $Red
    }
    
    if ($clientProcesses) {
        Write-ColorOutput "Client processes: $($clientProcesses.Count)" $Green
        foreach ($proc in $clientProcesses) {
            Write-ColorOutput "  - PID: $($proc.Id), Started: $($proc.StartTime)" $Yellow
        }
    } else {
        Write-ColorOutput "No client processes running" $Red
    }
}

# Main execution
switch ($Mode.ToLower()) {
    "server" {
        Start-Server -Port $Port -Background $Background
    }
    "client" {
        Start-Client -ServerIP $ServerIP -Port $Port -Background $Background
    }
    "demo" {
        Start-Demo -Port $Port -NumClients $NumClients -Background $Background
    }
    "status" {
        Show-Status
    }
    "help" {
        Show-Help
    }
    default {
        Write-ColorOutput "Unknown mode: $Mode" $Red
        Write-ColorOutput "Use '.\run.ps1 help' for usage information" $Yellow
        exit 1
    }
}
