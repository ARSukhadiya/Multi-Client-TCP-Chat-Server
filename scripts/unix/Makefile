# Makefile for Multi-Client TCP Chat Server
# Supports both Windows and Unix-like systems

# Configuration
CC = g++
CFLAGS = -std=c++11 -Wall -Wextra
LDFLAGS = 
SRC_DIR = src
BUILD_DIR = build
SERVER_SRC = $(SRC_DIR)/server.cpp
CLIENT_SRC = $(SRC_DIR)/client.cpp
SERVER_EXE = $(BUILD_DIR)/server.exe
CLIENT_EXE = $(BUILD_DIR)/client.exe

# Platform detection
ifeq ($(OS),Windows_NT)
    # Windows
    LDFLAGS += -lws2_32
    SERVER_EXE = $(BUILD_DIR)/server.exe
    CLIENT_EXE = $(BUILD_DIR)/client.exe
else
    # Unix-like systems
    LDFLAGS += -pthread
    SERVER_EXE = $(BUILD_DIR)/server
    CLIENT_EXE = $(BUILD_DIR)/client
endif

# Build types
ifeq ($(BUILD_TYPE),debug)
    CFLAGS += -g -O0 -DDEBUG
else
    CFLAGS += -O2 -DNDEBUG
endif

# Default target
.PHONY: all
all: $(SERVER_EXE) $(CLIENT_EXE)

# Build server
$(SERVER_EXE): $(SERVER_SRC)
	@echo "Compiling server..."
	$(CC) $(CFLAGS) -o $@ $< $(LDFLAGS)
	@echo "✓ Server compiled successfully"

# Build client
$(CLIENT_EXE): $(CLIENT_SRC)
	@echo "Compiling client..."
	$(CC) $(CFLAGS) -o $@ $< $(LDFLAGS)
	@echo "✓ Client compiled successfully"

# Build both with debug info
.PHONY: debug
debug: CFLAGS += -g -O0 -DDEBUG
debug: all

# Build both with release optimizations
.PHONY: release
release: CFLAGS += -O2 -DNDEBUG
release: all

# Clean build artifacts
.PHONY: clean
clean:
	@echo "Cleaning build artifacts..."
	rm -f $(BUILD_DIR)/*.exe $(BUILD_DIR)/*.o $(BUILD_DIR)/*.obj
	rm -f $(BUILD_DIR)/server $(BUILD_DIR)/client
	@echo "✓ Build artifacts cleaned"

# Clean all files (including temporary and log files)
.PHONY: clean-all
clean-all: clean
	@echo "Cleaning temporary files..."
	find . -name "*.tmp" -o -name "*.temp" -o -name "*.bak" -o -name "*.swp" -o -name "*.swo" -o -name "*~" | xargs rm -f 2>/dev/null || true
	@echo "Cleaning log files..."
	find . -name "*.log" -o -name "*.out" -o -name "*.err" | xargs rm -f 2>/dev/null || true
	@echo "✓ All files cleaned"

# Run tests
.PHONY: test
test: all
	@echo "Running tests..."
	@if command -v python3 >/dev/null 2>&1; then \
		python3 test.py; \
	elif command -v python >/dev/null 2>&1; then \
		python test.py; \
	else \
		echo "Python not found. Please install Python to run tests."; \
	fi

# Install dependencies (for Unix-like systems)
.PHONY: install-deps
install-deps:
	@echo "Installing dependencies..."
	@if command -v apt-get >/dev/null 2>&1; then \
		sudo apt-get update && sudo apt-get install -y build-essential; \
	elif command -v yum >/dev/null 2>&1; then \
		sudo yum groupinstall -y "Development Tools"; \
	elif command -v brew >/dev/null 2>&1; then \
		brew install gcc; \
	else \
		echo "Package manager not found. Please install g++ manually."; \
	fi

# Show help
.PHONY: help
help:
	@echo "Multi-Client TCP Chat Server - Makefile"
	@echo "======================================"
	@echo ""
	@echo "Available targets:"
	@echo "  all          - Build server and client (default)"
	@echo "  debug        - Build with debug information"
	@echo "  release      - Build with release optimizations"
	@echo "  clean        - Remove build artifacts"
	@echo "  clean-all    - Remove all generated files"
	@echo "  test         - Run automated tests"
	@echo "  install-deps - Install build dependencies"
	@echo "  help         - Show this help message"
	@echo ""
	@echo "Variables:"
	@echo "  CC           - C++ compiler (default: g++)"
	@echo "  BUILD_TYPE   - Build type: debug or release"
	@echo "  CFLAGS       - Compiler flags"
	@echo ""
	@echo "Examples:"
	@echo "  make"
	@echo "  make debug"
	@echo "  make clean"
	@echo "  make BUILD_TYPE=debug"
	@echo "  make CC=clang++"

# Check if compiler is available
.PHONY: check-compiler
check-compiler:
	@if ! command -v $(CC) >/dev/null 2>&1; then \
		echo "Error: Compiler '$(CC)' not found."; \
		echo "Please install a C++ compiler:"; \
		echo "  - Windows: Install MinGW-w64 or Visual Studio"; \
		echo "  - Linux: Run 'make install-deps' or install g++"; \
		echo "  - macOS: Install Xcode Command Line Tools"; \
		exit 1; \
	fi

# Pre-build check
$(SERVER_EXE) $(CLIENT_EXE): check-compiler
