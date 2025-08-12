@echo off
REM Clean script for Multi-Client TCP Chat Server (Batch version)
REM Removes build artifacts, temporary files, and cleans up the project

setlocal enabledelayedexpansion

REM Parse command line arguments
set CLEAN_ALL=0
set CLEAN_BUILD=0
set CLEAN_TEMP=0
set CLEAN_LOGS=0
set FORCE=0
set VERBOSE=0

:parse_args
if "%~1"=="" goto :main
if /i "%~1"=="--help" goto :show_help
if /i "%~1"=="-h" goto :show_help
if /i "%~1"=="--all" set CLEAN_ALL=1
if /i "%~1"=="-a" set CLEAN_ALL=1
if /i "%~1"=="--build" set CLEAN_BUILD=1
if /i "%~1"=="-b" set CLEAN_BUILD=1
if /i "%~1"=="--temp" set CLEAN_TEMP=1
if /i "%~1"=="-t" set CLEAN_TEMP=1
if /i "%~1"=="--logs" set CLEAN_LOGS=1
if /i "%~1"=="-l" set CLEAN_LOGS=1
if /i "%~1"=="--force" set FORCE=1
if /i "%~1"=="-f" set FORCE=1
if /i "%~1"=="--verbose" set VERBOSE=1
if /i "%~1"=="-v" set VERBOSE=1
shift
goto :parse_args

:show_help
echo Multi-Client TCP Chat Server - Clean Script
echo ===========================================
echo.
echo Usage: clean.bat [options]
echo.
echo Options:
echo   --help, -h           Show this help message
echo   --all, -a            Clean all types of files
echo   --build, -b          Clean build artifacts only
echo   --temp, -t           Clean temporary files only
echo   --logs, -l           Clean log files only
echo   --force, -f          Force deletion without confirmation
echo   --verbose, -v        Show detailed output
echo.
echo Examples:
echo   clean.bat
echo   clean.bat --all --verbose
echo   clean.bat --build --force
echo   clean.bat --temp --logs
echo.
goto :end

:main
echo Multi-Client TCP Chat Server - Clean Script

REM Show current disk usage
call :show_disk_usage

REM Determine what to clean
if %CLEAN_ALL%==1 (
    call :clean_all
) else if %CLEAN_BUILD%==1 (
    call :clean_build_artifacts
) else if %CLEAN_TEMP%==1 (
    call :clean_temp_files
) else if %CLEAN_LOGS%==1 (
    call :clean_log_files
) else (
    echo No specific target specified. Cleaning build artifacts...
    call :clean_build_artifacts
)

REM Show final disk usage
call :show_disk_usage

echo.
echo Clean operation completed!
goto :end

:clean_build_artifacts
echo.
echo === Cleaning Build Artifacts ===
set REMOVED_COUNT=0

REM Clean executables
echo Cleaning executables...
for /r %%f in (*.exe) do (
    if %VERBOSE%==1 echo   Removing: %%f
    del "%%f" /q 2>nul
    if not errorlevel 1 set /a REMOVED_COUNT+=1
)

REM Clean object files
echo Cleaning object files...
for /r %%f in (*.o *.obj) do (
    if %VERBOSE%==1 echo   Removing: %%f
    del "%%f" /q 2>nul
    if not errorlevel 1 set /a REMOVED_COUNT+=1
)

REM Clean library files
echo Cleaning library files...
for /r %%f in (*.dll *.so *.dylib *.a *.lib) do (
    if %VERBOSE%==1 echo   Removing: %%f
    del "%%f" /q 2>nul
    if not errorlevel 1 set /a REMOVED_COUNT+=1
)

REM Clean debug files
echo Cleaning debug files...
for /r %%f in (*.pdb *.ilk *.exp *.map) do (
    if %VERBOSE%==1 echo   Removing: %%f
    del "%%f" /q 2>nul
    if not errorlevel 1 set /a REMOVED_COUNT+=1
)

echo Total build artifacts removed: %REMOVED_COUNT%
goto :eof

:clean_temp_files
echo.
echo === Cleaning Temporary Files ===
set REMOVED_COUNT=0

REM Clean temporary files
echo Cleaning temporary files...
for /r %%f in (*.tmp *.temp *.bak *.swp *.swo) do (
    if %VERBOSE%==1 echo   Removing: %%f
    del "%%f" /q 2>nul
    if not errorlevel 1 set /a REMOVED_COUNT+=1
)

REM Clean backup files
echo Cleaning backup files...
for /r %%f in (*~) do (
    if %VERBOSE%==1 echo   Removing: %%f
    del "%%f" /q 2>nul
    if not errorlevel 1 set /a REMOVED_COUNT+=1
)

REM Clean system files
echo Cleaning system files...
for /r %%f in (.DS_Store Thumbs.db) do (
    if %VERBOSE%==1 echo   Removing: %%f
    del "%%f" /q 2>nul
    if not errorlevel 1 set /a REMOVED_COUNT+=1
)

echo Total temporary files removed: %REMOVED_COUNT%
goto :eof

:clean_log_files
echo.
echo === Cleaning Log Files ===
set REMOVED_COUNT=0

REM Clean log files
echo Cleaning log files...
for /r %%f in (*.log *.out *.err) do (
    if %VERBOSE%==1 echo   Removing: %%f
    del "%%f" /q 2>nul
    if not errorlevel 1 set /a REMOVED_COUNT+=1
)

echo Total log files removed: %REMOVED_COUNT%
goto :eof

:clean_all
echo.
echo === Full Clean ===
call :clean_build_artifacts
call :clean_temp_files
call :clean_log_files
echo.
echo ✓ Full clean completed!
goto :eof

:show_disk_usage
echo.
echo === Current Disk Usage ===
for /f "tokens=3" %%a in ('dir /-c ^| find "File(s)"') do set SIZE=%%a
echo Project size: %SIZE% bytes
goto :eof

:end
