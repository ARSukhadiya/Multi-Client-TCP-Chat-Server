# Quick Fixes Reference Card

## 🚨 Most Common Issues & Immediate Solutions

### 1. PowerShell Script Won't Run
**Error**: `File cannot be loaded because running scripts is disabled`

**Quick Fix**:
```powershell
powershell -ExecutionPolicy Bypass -File ".\scripts\windows\build.ps1"
```

### 2. Only Server Built, Client Missing
**Error**: Only `server.exe` exists in `build/` folder

**Quick Fix**:
```powershell
cd src
g++ -std=c++11 -Wall -Wextra -O2 -DNDEBUG -o ../build/client.exe client.cpp -lws2_32
cd ..
```

### 3. Port Already in Use
**Error**: `Warning: Port 8080 is already in use`

**Quick Fix**:
```powershell
# Kill processes using port 8080
netstat -ano | findstr :8080
taskkill /PID <PID> /F

# Or use different port
.\scripts\windows\run.ps1 server 8081
```

### 4. Compiler Not Found
**Error**: `Error: Compiler 'g++' not found`

**Quick Fix**:
1. Install [MSYS2](https://www.msys2.org/)
2. Add `C:\msys64\ucrt64\bin` to PATH
3. Restart terminal

### 5. Test Script Syntax Error
**Error**: `The Try statement is missing its Catch or Finally block`

**Quick Fix**:
```powershell
# Use the simplified test script
powershell -ExecutionPolicy Bypass -File ".\scripts\windows\test.ps1"
```

---

## 🔧 Essential Commands

### Build Project
```powershell
powershell -ExecutionPolicy Bypass -File ".\scripts\windows\build.ps1"
```

### Run Tests
```powershell
powershell -ExecutionPolicy Bypass -File ".\scripts\windows\test.ps1"
```

### Clean Build
```powershell
powershell -ExecutionPolicy Bypass -File ".\scripts\windows\clean.ps1"
```

### Start Server
```powershell
powershell -ExecutionPolicy Bypass -File ".\scripts\windows\run.ps1" server 8080
```

### Start Client
```powershell
powershell -ExecutionPolicy Bypass -File ".\scripts\windows\run.ps1" client 127.0.0.1 8080
```

---

## 📁 File Locations

- **Source**: `src/client.cpp`, `src/server.cpp`
- **Build**: `build/client.exe`, `build/server.exe`
- **Scripts**: `scripts/windows/`
- **Docs**: `docs/`

---

## ⚡ One-Liner Solutions

### Build Everything
```powershell
powershell -ExecutionPolicy Bypass -File ".\scripts\windows\build.ps1" -Verbose
```

### Test Everything
```powershell
powershell -ExecutionPolicy Bypass -File ".\scripts\windows\test.ps1" -Verbose
```

### Clean Everything
```powershell
powershell -ExecutionPolicy Bypass -File ".\scripts\windows\clean.ps1" -All
```

### Run Demo
```powershell
powershell -ExecutionPolicy Bypass -File ".\scripts\windows\run.ps1" demo 8080 -NumClients 3
```

---

## 🆘 Emergency Fixes

### If Nothing Works
1. **Clean everything**:
   ```powershell
   powershell -ExecutionPolicy Bypass -File ".\scripts\windows\clean.ps1" -All
   ```

2. **Rebuild everything**:
   ```powershell
   powershell -ExecutionPolicy Bypass -File ".\scripts\windows\build.ps1" -Verbose
   ```

3. **Test manually**:
   ```powershell
   cd build
   .\server.exe 8080
   # In another terminal:
   .\client.exe 127.0.0.1 8080
   ```

### If Scripts Are Broken
1. **Use batch files**:
   ```cmd
   cmd /c scripts\windows\build.bat
   ```

2. **Use Unix commands** (if available):
   ```bash
   make -f scripts/unix/Makefile
   ```

3. **Manual compilation**:
   ```bash
   cd src
   g++ -std=c++11 -Wall -Wextra -O2 -DNDEBUG -o ../build/server.exe server.cpp -lws2_32
   g++ -std=c++11 -Wall -Wextra -O2 -DNDEBUG -o ../build/client.exe client.cpp -lws2_32
   cd ..
   ```

---

## 📞 Need More Help?

1. **Check detailed troubleshooting**: `docs/TROUBLESHOOTING.md`
2. **Check script documentation**: `scripts/README.md`
3. **Check main documentation**: `README.md`
4. **Use verbose output**: Add `-Verbose` to any command
5. **Check prerequisites**: Ensure g++ compiler is installed and in PATH
