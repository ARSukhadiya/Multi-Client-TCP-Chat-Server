# Development Automation Scripts

This directory contains shell scripts and automation tools for the Multi-Client TCP Chat Server project. These scripts help streamline the development workflow by automating common tasks like building, testing, cleaning, and running the application.

## 📁 Project Structure

```
scripts/
├── windows/            # Windows-specific scripts
│   ├── build.ps1       # PowerShell build script
│   ├── build.bat       # Batch build script
│   ├── clean.ps1       # PowerShell cleanup script
│   ├── clean.bat       # Batch cleanup script
│   ├── test.ps1        # PowerShell testing script
│   └── run.ps1         # PowerShell run script
├── unix/               # Unix-like systems
│   └── Makefile        # Cross-platform build system
└── README.md           # This file
```

## 📁 Scripts Overview

### PowerShell Scripts (Windows)
- **`build.ps1`** - Compiles the C++ code with proper flags and error handling
- **`test.ps1`** - Runs automated tests to verify functionality
- **`clean.ps1`** - Removes build artifacts and temporary files
- **`run.ps1`** - Easy commands to start server and clients

### Batch Scripts (Windows)
- **`build.bat`** - Windows batch version of the build script
- **`clean.bat`** - Windows batch version of the clean script

### Makefile (Cross-platform)
- **`Makefile`** - Unix-like systems and cross-platform compatibility

## 🚀 Quick Start

### Windows (PowerShell)
```powershell
# Build the project
.\scripts\windows\build.ps1

# Run tests
.\scripts\windows\test.ps1

# Start server
.\scripts\windows\run.ps1 server 8080

# Start client
.\scripts\windows\run.ps1 client 127.0.0.1 8080

# Run demo with multiple clients
.\scripts\windows\run.ps1 demo 8080 -NumClients 3

# Clean build artifacts
.\scripts\windows\clean.ps1
```

### Windows (Command Prompt)
```cmd
# Build the project
scripts\windows\build.bat

# Clean build artifacts
scripts\windows\clean.bat

# Build with debug info
scripts\windows\build.bat --debug --verbose
```

### Unix-like Systems
```bash
# Build the project
make -f scripts/unix/Makefile

# Build with debug info
make -f scripts/unix/Makefile debug

# Run tests
make -f scripts/unix/Makefile test

# Clean build artifacts
make -f scripts/unix/Makefile clean

# Show help
make -f scripts/unix/Makefile help
```

## 📋 Script Details

### Build Script (`build.ps1` / `build.bat`)

**Features:**
- Compiles both server and client executables
- Supports debug and release builds
- Automatic compiler detection
- Colored output for better readability
- Error handling and validation

**Usage:**
```powershell
# Basic build
.\build.ps1

# Debug build with verbose output
.\build.ps1 -BuildType Debug -Verbose

# Clean build (removes old artifacts first)
.\build.ps1 -Clean

# Specify custom compiler
.\build.ps1 -Compiler clang++
```

**Options:**
- `-BuildType`: Debug or Release (default: Release)
- `-Compiler`: Specify compiler (default: g++)
- `-Clean`: Clean build artifacts before building
- `-Verbose`: Show detailed compilation output

### Test Script (`test.ps1`)

**Features:**
- Automated connectivity testing
- Message broadcasting verification
- Stress testing with multiple connections
- Integration test suite
- Automatic server startup and cleanup

**Usage:**
```powershell
# Run all tests
.\test.ps1

# Test on specific port
.\test.ps1 -Port 9000

# Verbose test output
.\test.ps1 -Verbose

# Keep processes running after tests
.\test.ps1 -NoCleanup
```

**Test Types:**
1. **Basic Connectivity** - Verifies server is reachable
2. **Message Broadcasting** - Tests message sending/receiving
3. **Stress Test** - Multiple simultaneous connections
4. **Integration Test** - Full workflow verification

### Clean Script (`clean.ps1` / `clean.bat`)

**Features:**
- Removes build artifacts (executables, object files)
- Cleans temporary files (backup, swap files)
- Removes log files
- Shows disk usage before and after
- Safe deletion with confirmation

**Usage:**
```powershell
# Clean build artifacts only (default)
.\clean.ps1

# Clean all file types
.\clean.ps1 -All

# Clean specific types
.\clean.ps1 -Build -Temp -Logs

# Force deletion without prompts
.\clean.ps1 -All -Force

# Verbose output
.\clean.ps1 -All -Verbose
```

**Clean Types:**
- `-Build`: Executables, object files, libraries
- `-Temp`: Temporary files, backups, swap files
- `-Logs`: Log files, output files, error files
- `-All`: All of the above

### Run Script (`run.ps1`)

**Features:**
- Easy server and client startup
- Demo mode with multiple clients
- Background and foreground execution
- Process status monitoring
- Port availability checking

**Usage:**
```powershell
# Show help
.\run.ps1 help

# Start server
.\run.ps1 server 8080

# Start client
.\run.ps1 client 127.0.0.1 8080

# Run demo with 3 clients
.\run.ps1 demo 8080 -NumClients 3

# Run in background
.\run.ps1 server -Background

# Check process status
.\run.ps1 status
```

**Modes:**
- `server [port]` - Start server on specified port
- `client [ip] [port]` - Start client connecting to server
- `demo [port]` - Start server and multiple clients
- `status` - Show running processes
- `help` - Display usage information

### Makefile

**Features:**
- Cross-platform compatibility
- Platform detection (Windows vs Unix)
- Multiple build targets
- Dependency management
- Automated testing

**Usage:**
```bash
# Build everything
make

# Debug build
make debug

# Release build
make release

# Clean build artifacts
make clean

# Clean everything
make clean-all

# Run tests
make test

# Install dependencies
make install-deps

# Show help
make help
```

## 🔧 Configuration

### Environment Variables

The scripts automatically detect your environment, but you can customize:

**PowerShell:**
```powershell
$env:CC = "clang++"  # Custom compiler
$env:BUILD_TYPE = "Debug"  # Build type
```

**Unix-like:**
```bash
export CC=clang++  # Custom compiler
export BUILD_TYPE=debug  # Build type
```

### Compiler Requirements

- **Windows**: MinGW-w64 (recommended) or Visual Studio
- **Linux**: GCC (install with `make install-deps`)
- **macOS**: Xcode Command Line Tools

## 🐛 Troubleshooting

### Common Issues

1. **Compiler not found**
   ```
   Error: Compiler 'g++' not found
   ```
   **Solution**: Install MinGW-w64 or update PATH

2. **Port already in use**
   ```
   Error: Port 8080 is already in use
   ```
   **Solution**: Stop existing server or use different port

3. **Permission denied**
   ```
   Error: Permission denied
   ```
   **Solution**: Run as administrator or check file permissions

4. **PowerShell execution policy**
   ```
   Error: Cannot run script
   ```
   **Solution**: Run `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`

### Getting Help

- Run `.\run.ps1 help` for usage information
- Run `make help` for Makefile options
- Check the main README.md for project setup
- Review script source code for detailed options

## 📝 Contributing

When adding new scripts or modifying existing ones:

1. **Maintain consistency** with existing script patterns
2. **Add help text** for all new options
3. **Include error handling** for robust operation
4. **Test on multiple platforms** when possible
5. **Update this README** with new features

## 🔄 Workflow Integration

### Typical Development Workflow

```powershell
# 1. Clean previous build
.\clean.ps1

# 2. Build project
.\build.ps1 -BuildType Debug

# 3. Run tests
.\test.ps1

# 4. Start development server
.\run.ps1 server 8080 -Background

# 5. Start client for testing
.\run.ps1 client 127.0.0.1 8080
```

### CI/CD Integration

These scripts can be easily integrated into CI/CD pipelines:

```yaml
# Example GitHub Actions workflow
- name: Build and Test
  run: |
    .\build.ps1 -BuildType Release
    .\test.ps1 -Port 8080
    .\clean.ps1 -All
```

## 📊 Performance Tips

- Use `-Background` flag for non-interactive testing
- Run `clean.ps1` regularly to free disk space
- Use `-Verbose` only when debugging
- Consider using different ports for parallel development
