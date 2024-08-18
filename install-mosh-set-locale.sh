#!/bin/bash

# Set variables
USERNAME="moshuser"
MOSH_SERVICE_FILE="/etc/systemd/system/mosh-server.service"

# Function to select language
select_language() {
    echo "Select language / Выберите язык / Wählen Sie die Sprache:"
    echo "1. English"
    echo "2. Русский"
    echo "3. Deutsch"
    read -p "Enter your choice (1/2/3): " lang_choice

    case $lang_choice in
        1) LANG_SETTING="en_US.UTF-8" ;;
        2) LANG_SETTING="ru_RU.UTF-8" ;;
        3) LANG_SETTING="de_DE.UTF-8" ;;
        *) echo "Invalid choice. Defaulting to English."; LANG_SETTING="en_US.UTF-8" ;;
    esac
}

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

# Select language
select_language

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
sudo locale-gen $LANG_SETTING

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
Environment="LANG=$LANG_SETTING"
Environment="LC_ALL=$LANG_SETTING"

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
