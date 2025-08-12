@echo off
REM Build script for Multi-Client TCP Chat Server (Batch version)
REM Compiles both server and client executables

setlocal enabledelayedexpansion

REM Parse command line arguments
set COMPILER=g++
set BUILD_TYPE=Release
set CLEAN=0
set VERBOSE=0

:parse_args
if "%~1"=="" goto :main
if /i "%~1"=="--help" goto :show_help
if /i "%~1"=="-h" goto :show_help
if /i "%~1"=="--clean" set CLEAN=1
if /i "%~1"=="-c" set CLEAN=1
if /i "%~1"=="--verbose" set VERBOSE=1
if /i "%~1"=="-v" set VERBOSE=1
if /i "%~1"=="--debug" set BUILD_TYPE=Debug
if /i "%~1"=="--release" set BUILD_TYPE=Release
if /i "%~1"=="--compiler" (
    set COMPILER=%~2
    shift
)
shift
goto :parse_args

:show_help
echo Multi-Client TCP Chat Server - Build Script
echo ===========================================
echo.
echo Usage: build.bat [options]
echo.
echo Options:
echo   --help, -h           Show this help message
echo   --clean, -c          Clean build artifacts before building
echo   --verbose, -v        Show verbose output
echo   --debug              Build in debug mode
echo   --release            Build in release mode (default)
echo   --compiler ^<name^>    Specify compiler (default: g++)
echo.
echo Examples:
echo   build.bat
echo   build.bat --clean --verbose
echo   build.bat --debug
echo   build.bat --compiler cl
echo.
goto :end

:main
echo Building Multi-Client TCP Chat Server...
echo Compiler: %COMPILER%
echo Build Type: %BUILD_TYPE%

REM Check if compiler exists
where %COMPILER% >nul 2>&1
if errorlevel 1 (
    echo Error: Compiler '%COMPILER%' not found. Please install MinGW-w64 or update your PATH.
    echo Installation guide: https://www.msys2.org/
    exit /b 1
)

REM Set compiler flags based on build type
set COMMON_FLAGS=-std=c++11 -Wall -Wextra
set LINK_FLAGS=-lws2_32

if "%BUILD_TYPE%"=="Debug" (
    set COMMON_FLAGS=%COMMON_FLAGS% -g -O0 -DDEBUG
) else (
    set COMMON_FLAGS=%COMMON_FLAGS% -O2 -DNDEBUG
)

if %VERBOSE%==1 (
    set COMMON_FLAGS=%COMMON_FLAGS% -v
)

REM Change to src directory
cd src

REM Clean build artifacts if requested
if %CLEAN%==1 (
    echo Cleaning build artifacts...
    del /q *.exe *.o *.obj *.dll *.so *.dylib *.a *.lib *.pdb *.ilk *.exp *.map 2>nul
    echo Build artifacts cleaned.
)

REM Build server
echo Compiling server...
if %VERBOSE%==1 (
    echo Command: %COMPILER% %COMMON_FLAGS% -o ../build/server.exe server.cpp %LINK_FLAGS%
)
%COMPILER% %COMMON_FLAGS% -o ../build/server.exe server.cpp %LINK_FLAGS%
if errorlevel 1 (
    echo Server compilation failed!
    exit /b 1
)
echo ✓ Server compiled successfully

REM Build client
echo Compiling client...
if %VERBOSE%==1 (
    echo Command: %COMPILER% %COMMON_FLAGS% -o ../build/client.exe client.cpp %LINK_FLAGS%
)
%COMPILER% %COMMON_FLAGS% -o ../build/client.exe client.cpp %LINK_FLAGS%
if errorlevel 1 (
    echo Client compilation failed!
    exit /b 1
)
echo ✓ Client compiled successfully

REM Show build results
echo.
echo Build completed successfully!
echo Generated files:
dir ../build/*.exe /b

REM Return to original directory
cd ..

:end
