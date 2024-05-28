#!/bin/bash

# Check if the script is running on a Linux system with apt package manager
if ! [ -x "$(command -v apt)" ]; then
    echo -e "\e[31mThis script is intended for use on Linux systems with the apt package manager.\e[0m"
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

# Function to determine if sudo is required
may_need_sudo() {
    [[ $EUID -ne 0 ]] && echo "sudo"
}

SUDO=$(may_need_sudo)

# Verify sudo access
if [ "$SUDO" ]; then
    if ! $SUDO -v &> /dev/null; then
        echo -e "\e[31mSudo password is incorrect. Please run the script again with correct sudo password.\e[0m"
        exit 1
    fi
fi

# Update system packages
echo -e "\e[33mUpdating system packages...\e[0m"
$SUDO apt update -y

# Install required packages
for pkg in ffmpeg curl; do
    command -v $pkg &> /dev/null || $SUDO apt -y install $pkg
done

# Install Node.js version 20 if not already installed
install_nodejs() {
    echo -e "\e[33mInstalling Node.js version 20...\e[0m"
    curl -fsSL https://deb.nodesource.com/setup_20.x | $SUDO -E bash -
    $SUDO apt-get install -y nodejs
}

# Check for Node.js version and install if necessary
if command -v node &> /dev/null; then
    CURRENT_NODE_VERSION=$(node -v | cut -d. -f1)
    if [[ "$CURRENT_NODE_VERSION" != "v20" ]]; then
        install_nodejs
    else
        echo -e "\e[32mNode.js version 20 or higher is already installed.\e[0m"
    fi
else
    install_nodejs
fi

# Install Yarn if not already installed
if ! command -v yarn &> /dev/null; then
    echo -e "\e[33mInstalling Yarn...\e[0m"
    npm install -g yarn
else
    echo -e "\e[32mYarn is already installed.\e[0m"
fi

# Install PM2 if not already installed
if ! command -v pm2 &> /dev/null; then
    echo -e "\e[33mInstalling PM2...\e[0m"
    yarn global add pm2
else
    echo -e "\e[32mPM2 is already installed.\e[0m"
fi

# Install dependencies from package.json
echo -e "\e[33mInstalling dependencies with Yarn...\e[0m"
yarn install --network-concurrency 1 &>/dev/null

# Start the application using PM2
echo -e "\e[33mStarting the bot...\e[0m"
pm2 start index.js --name my-bot
