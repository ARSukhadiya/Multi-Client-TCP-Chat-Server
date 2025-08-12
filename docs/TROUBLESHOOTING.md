# Troubleshooting Guide

This document provides solutions to common challenges and errors encountered when working with the Multi-Client TCP Chat Server project.

## Table of Contents

1. [PowerShell Execution Policy Issues](#powershell-execution-policy-issues)
2. [Script Syntax Errors](#script-syntax-errors)
3. [Build Process Issues](#build-process-issues)
4. [Folder Structure Organization](#folder-structure-organization)
5. [Testing Issues](#testing-issues)
6. [Cross-Platform Compatibility](#cross-platform-compatibility)

---

## PowerShell Execution Policy Issues

### Problem
PowerShell scripts fail to run with the error:
```
File cannot be loaded because running scripts is disabled on this system.
For more information, see about_Execution_Policies at https:/go.microsoft.com/fwlink/?LinkID=135170
```

### Root Cause
Windows PowerShell has a security feature that prevents script execution by default to protect against malicious scripts.

### Solutions

#### Solution 1: Use Execution Policy Bypass (Recommended)
```powershell
# Run any PowerShell script with bypass
powershell -ExecutionPolicy Bypass -File ".\scripts\windows\build.ps1"
powershell -ExecutionPolicy Bypass -File ".\scripts\windows\test.ps1"
powershell -ExecutionPolicy Bypass -File ".\scripts\windows\clean.ps1"
powershell -ExecutionPolicy Bypass -File ".\scripts\windows\run.ps1"
```

#### Solution 2: Use Helper Scripts (Root Directory)
Helper scripts in the root directory automatically bypass execution policy:
```powershell
# These work from the root directory
.\build.ps1
.\clean.ps1
.\test.ps1
.\run.ps1
```

#### Solution 3: Change Execution Policy (Permanent)
```powershell
# Run as Administrator
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

#### Solution 4: Use Batch Files
```cmd
# From the root directory
cmd /c scripts\windows\build.bat
cmd /c scripts\windows\clean.bat
```

---

## Script Syntax Errors

### Problem 1: Missing Catch or Finally Block
```
The Try statement is missing its Catch or Finally block.
Unexpected token '}' in expression or statement.
```

### Root Cause
PowerShell requires every `try` block to have either a `catch` or `finally` block (or both).

### Solution
```powershell
# Incorrect
try {
    # code
}

# Correct
try {
    # code
}
catch {
    # error handling
}
finally {
    # cleanup
}
```

### Problem 2: String Interpolation Issues
```
Unexpected token 'connections' in expression or statement.
Missing closing ')' in expression.
```

### Root Cause
Complex string interpolation with variables and special characters can confuse the PowerShell parser.

### Solution
```powershell
# Problematic
Write-ColorOutput "`n=== Running Stress Test ($NumConnections connections) ===" $Blue

# Fixed - Use string formatting
$message = "`n=== Running Stress Test ({0} connections) ===" -f $NumConnections
Write-ColorOutput $message $Blue

# Alternative - Use simple concatenation
Write-ColorOutput ("`n=== Running Stress Test " + $NumConnections + " connections ===") $Blue
```

---

## Build Process Issues

### Problem 1: Only Server Compiles, Client Missing
The build script only generates `server.exe` but not `client.exe`.

### Root Cause
The build script may exit early due to an error in the server compilation step.

### Solution
1. Check if the server compilation actually succeeded
2. Ensure both compilation steps are executed
3. Use verbose output to see detailed compilation logs:
```powershell
powershell -ExecutionPolicy Bypass -File ".\scripts\windows\build.ps1" -Verbose
```

### Problem 2: Compiler Not Found
```
Error: Compiler 'g++' not found. Please install MinGW-w64 or update your PATH.
```

### Root Cause
The C++ compiler is not installed or not in the system PATH.

### Solution
1. Install MinGW-w64 from [MSYS2](https://www.msys2.org/)
2. Add the compiler path to your Windows PATH environment variables
3. Typical path: `C:\msys64\ucrt64\bin`

### Problem 3: Batch File Encoding Issues
```
'Build' is not recognized as an internal or external command
```

### Root Cause
Batch files may have incorrect line endings or encoding issues.

### Solution
1. Ensure batch files use Windows line endings (CRLF)
2. Save files with UTF-8 encoding without BOM
3. Use PowerShell scripts instead of batch files when possible

---

## Folder Structure Organization

### Problem
Scripts and source files are scattered across different directories, making the project hard to navigate.

### Solution
Reorganized the project structure:
```
Multi-Client-TCP-Chat-Server/
├── src/                    # Source code
│   ├── client.cpp
│   └── server.cpp
├── build/                  # Build artifacts (auto-generated)
│   ├── client.exe
│   └── server.exe
├── scripts/                # Automation scripts
│   ├── windows/            # Windows-specific scripts
│   │   ├── build.ps1
│   │   ├── build.bat
│   │   ├── clean.ps1
│   │   ├── clean.bat
│   │   ├── test.ps1
│   │   └── run.ps1
│   ├── unix/               # Unix-like systems
│   │   └── Makefile
│   └── README.md
├── docs/                   # Documentation
│   └── Client-Server-demo.gif
├── README.md
└── .gitignore
```

### Benefits
- Clear separation of concerns
- Easy to find and maintain scripts
- Cross-platform compatibility
- Professional project structure

---

## Testing Issues

### Problem 1: Server Won't Start in Tests
```
Cannot connect to server
Some tests failed
```

### Root Cause
The server process may not be starting properly or may be taking longer than expected to start.

### Solution
1. Increase the wait time for server startup
2. Add better error handling and logging
3. Check if the port is already in use
4. Verify the server executable exists and is working

### Problem 2: Port Already in Use
```
Warning: Port 8080 is already in use
```

### Root Cause
Another process is using the same port.

### Solution
1. Stop any existing server processes
2. Use a different port:
```powershell
.\scripts\windows\test.ps1 -Port 8081
```
3. Kill processes using the port:
```powershell
netstat -ano | findstr :8080
taskkill /PID <PID> /F
```

---

## Cross-Platform Compatibility

### Problem
Scripts work on Windows but not on Unix-like systems.

### Solution
1. **Windows**: Use PowerShell scripts in `scripts/windows/`
2. **Unix-like**: Use Makefile in `scripts/unix/`
3. **Cross-platform**: Use the appropriate script for your platform

### Usage Examples

#### Windows (PowerShell)
```powershell
# Build the project
.\scripts\windows\build.ps1

# Run tests
.\scripts\windows\test.ps1

# Start server
.\scripts\windows\run.ps1 server 8080

# Clean build artifacts
.\scripts\windows\clean.ps1
```

#### Unix-like Systems
```bash
# Build the project
make -f scripts/unix/Makefile

# Run tests
make -f scripts/unix/Makefile test

# Clean build artifacts
make -f scripts/unix/Makefile clean
```

---

## Common Error Messages and Solutions

| Error Message | Cause | Solution |
|---------------|-------|----------|
| `File cannot be loaded because running scripts is disabled` | PowerShell execution policy | Use `-ExecutionPolicy Bypass` or change policy |
| `The Try statement is missing its Catch or Finally block` | Incomplete try-catch structure | Add missing catch or finally block |
| `Unexpected token 'connections' in expression` | String interpolation issue | Use string formatting with `-f` operator |
| `Error: Compiler 'g++' not found` | Missing C++ compiler | Install MinGW-w64 and add to PATH |
| `Warning: Port 8080 is already in use` | Port conflict | Use different port or kill existing process |
| `Cannot connect to server` | Server not starting | Check server executable and increase wait time |
| `'Build' is not recognized as an internal or external command` | Batch file encoding issue | Use PowerShell scripts instead |

---

## Best Practices

### 1. Always Use Execution Policy Bypass
```powershell
powershell -ExecutionPolicy Bypass -File "script.ps1"
```

### 2. Use Verbose Output for Debugging
```powershell
.\scripts\windows\build.ps1 -Verbose
```

### 3. Check Prerequisites
- Ensure C++ compiler is installed and in PATH
- Verify all required files exist
- Check port availability

### 4. Use Proper Error Handling
```powershell
try {
    # risky operation
}
catch {
    Write-Error "Operation failed: $_"
    exit 1
}
finally {
    # cleanup
}
```

### 5. Test on Multiple Platforms
- Test Windows scripts on Windows
- Test Unix scripts on Linux/macOS
- Verify cross-platform compatibility

---

## Getting Help

If you encounter issues not covered in this guide:

1. **Check the logs**: Use `-Verbose` flag for detailed output
2. **Verify prerequisites**: Ensure all required tools are installed
3. **Check file paths**: Verify all files exist in expected locations
4. **Test manually**: Try running commands manually to isolate issues
5. **Check documentation**: Refer to `scripts/README.md` for detailed script documentation

---

## Quick Reference

### Essential Commands
```powershell
# Build project
powershell -ExecutionPolicy Bypass -File ".\scripts\windows\build.ps1"

# Run tests
powershell -ExecutionPolicy Bypass -File ".\scripts\windows\test.ps1"

# Clean build artifacts
powershell -ExecutionPolicy Bypass -File ".\scripts\windows\clean.ps1"

# Start server
powershell -ExecutionPolicy Bypass -File ".\scripts\windows\run.ps1" server 8080

# Start client
powershell -ExecutionPolicy Bypass -File ".\scripts\windows\run.ps1" client 127.0.0.1 8080
```

### Common Ports
- **Default server port**: 8080
- **Alternative ports**: 8081, 8082, 9000
- **Check port usage**: `netstat -ano | findstr :8080`

### File Locations
- **Source code**: `src/client.cpp`, `src/server.cpp`
- **Build artifacts**: `build/client.exe`, `build/server.exe`
- **Scripts**: `scripts/windows/` (Windows), `scripts/unix/` (Unix)
- **Documentation**: `docs/`, `README.md`, `scripts/README.md`
