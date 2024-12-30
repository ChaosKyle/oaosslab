#!/bin/bash

# Detect the operating system
OS=$(uname -s)

# Function to install requirements on Mac
install_mac() {
    echo "Detected macOS"
    echo "Installing Homebrew (if not installed)..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    echo "Installing required tools..."
    brew install docker kubectl kind opentofu

    echo "Starting Docker Desktop (if installed)..."
    open -a Docker

    echo "Verifying installations..."
    docker --version
    kubectl version --client
    kind version
    tofu version

    echo "Installation completed for macOS."
}

# Function to install requirements on Windows
install_windows() {
    echo "Detected Windows"

    echo "Checking for Chocolatey (if not installed)..."
    if ! choco -v > /dev/null 2>&1; then
        echo "Installing Chocolatey..."
        powershell -NoProfile -ExecutionPolicy Bypass -Command \
            "[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; \
            iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
    fi

    echo "Installing required tools..."
    choco install -y docker-desktop kubernetes-cli kind opentofu

    echo "Starting Docker Desktop (if installed)..."
    start "" "C:\\Program Files\\Docker\\Docker\\Docker Desktop.exe"

    echo "Verifying installations..."
    docker --version
    kubectl version --client
    kind version
    tofu version

    echo "Installation completed for Windows."
}

# Main script execution
if [ "$OS" == "Darwin" ]; then
    install_mac
elif [[ "$OS" == *"NT"* || "$OS" == *"MINGW"* || "$OS" == *"CYGWIN"* ]]; then
    install_windows
else
    echo "Unsupported operating system. Please install tools manually."
    exit 1
fi

# Happy success message with ASCII art
echo "
=========================================
Installation Successful! 🎉
=========================================
     \   ^__^
      \  (oo)\_______
         (__)\       )\/\
             ||----w |
             ||     ||
=========================================
"
