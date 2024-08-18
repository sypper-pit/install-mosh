#!/bin/bash

# Set variables
USERNAME="moshuser"
MOSH_SERVICE_FILE="/etc/systemd/system/mosh-server.service"

# Function to detect OS
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
    elif type lsb_release >/dev/null 2>&1; then
        OS=$(lsb_release -si)
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        OS=$DISTRIB_ID
    else
        OS=$(uname -s)
    fi
}

# Function to install Mosh
install_mosh() {
    echo "Installing Mosh..."
    case $OS in
        "Ubuntu"|"Debian")
            sudo apt-get update
            sudo apt-get install -y mosh
            ;;
        "CentOS"|"Red Hat Enterprise Linux")
            sudo yum install -y epel-release
            sudo yum install -y mosh
            ;;
        "Fedora")
            sudo dnf install -y mosh
            ;;
        *)
            echo "Unsupported OS for automatic Mosh installation. Please install Mosh manually."
            exit 1
            ;;
    esac
}

# Detect OS
detect_os

# Check if Mosh is installed, if not, install it
if ! command -v mosh-server &> /dev/null; then
    install_mosh
else
    echo "Mosh is already installed."
fi

# Create the user
echo "Creating user $USERNAME..."
sudo useradd -m -s /bin/bash $USERNAME

# Set up locale
echo "Setting up locale..."
sudo locale-gen ru_RU.UTF-8

# Create mosh-server service file
echo "Creating mosh-server service file..."
sudo tee $MOSH_SERVICE_FILE > /dev/null <<EOL
[Unit]
Description=Mosh Server
After=network.target

[Service]
ExecStart=/usr/bin/mosh-server
Restart=on-failure
User=$USERNAME
Environment="LANG=ru_RU.UTF-8"
Environment="LC_ALL=ru_RU.UTF-8"

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd to recognize the new service
echo "Reloading systemd..."
sudo systemctl daemon-reload

# Enable and start the mosh-server service
echo "Enabling and starting mosh-server service..."
sudo systemctl enable mosh-server.service
sudo systemctl start mosh-server.service

echo "Mosh server setup complete!"
