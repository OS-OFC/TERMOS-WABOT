
#!/bin/bash

if ! [ -x "$(command -v apt)" ]; then
    echo -e "\e[31mThis script is intended for use on Linux systems with the apt package manager.\e[0m"
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

may_need_sudo() {
    [[ $EUID -ne 0 ]] && echo "sudo"
}

SUDO=$(may_need_sudo)

if [ "$SUDO" ]; then
    if ! $SUDO -v &> /dev/null; then
        echo -e "\e[31mSudo password is incorrect. Please run the script again with correct sudo password.\e[0m"
        exit 1
    fi
fi

echo -e "\e[36mEnter a name for BOT (e.g., levanter):\e[0m"
read -p "" BOT_NAME
BOT_NAME=${BOT_NAME:-levanter}

if [ -d "$BOT_NAME" ]; then
    RANDOM_SUFFIX=$((1 + RANDOM % 1000))
    BOT_NAME="$BOT_NAME$RANDOM_SUFFIX"
    echo -e "\e[33mFolder with the same name already exists. Renaming to $BOT_NAME.\e[0m"
fi

echo -e "\e[36mDo you have a SESSION_ID scanned today? (y/n):\e[0m"
read -p "" HAS_SESSION_ID
SESSION_ID="oussamabakrine"
if [[ "$HAS_SESSION_ID" == "y" ]]; then
    echo -e "\e[36mEnter Your SESSION_ID:\e[0m"
    read -p "" 
fi

install_nodejs() {
    echo -e "\e[33mInstalling Node.js version 20...\e[0m"
    curl -fsSL https://deb.nodesource.com/setup_20.x | $SUDO -E bash -
    $SUDO apt-get install -y nodejs
}

uninstall_nodejs() {
    echo -e "\e[33mRemoving existing Node.js installation...\e[0m"
    $SUDO apt-get remove -y nodejs
    $SUDO apt-get autoremove -y
}

echo -e "\e[33mUpdating system packages...\e[0m"
$SUDO apt update -y

for pkg in git ffmpeg curl; do
    command -v $pkg &> /dev/null || $SUDO apt -y install $pkg
done

# Check for Node.js version and uninstall if necessary
if command -v node &> /dev/null; then
    CURRENT_NODE_VERSION=$(node -v | cut -d. -f1)
    if [[ "$CURRENT_NODE_VERSION" != "v20" ]]; then
        uninstall_nodejs
        install_nodejs
    else
        echo -e "\e[32mNode.js version 20 or higher is already installed.\e[0m"
    fi
else
    install_nodejs
fi

if ! command -v yarn &> /dev/null; then
    echo -e "\e[33mInstalling Yarn...\e[0m"
    npm install -g yarn
else
    echo -e "\e[32mYarn is already installed.\e[0m"
fi

if ! command -v pm2 &> /dev/null; then
    echo -e "\e[33mInstalling PM2...\e[0m"
    yarn global add pm2
else
    echo -e "\e[32mPM2 is already installed.\e[0m"
fi

echo -e "\e[33mCloning Levanter repository...\e[0m"
git clone https://github.com/lyfe00011/whatsapp-bot-md "$BOT_NAME" &>/dev/null
cd "$BOT_NAME" || exit 1
echo -e "\e[33mInstalling dependencies with Yarn...\e[0m"
yarn install --network-concurrency 1 &>/dev/null

echo -e "\e[33mCreating config.env file...\e[0m"
cat >config.env <<EOL
PREFIX=.
STICKER_PACKNAME=LyFE
ALWAYS_ONLINE=false
RMBG_KEY=null
LANGUAG=en
WARN_LIMIT=3
FORCE_LOGOUT=false
BRAINSHOP=159501,6pq8dPiYt7PdqHz3
MAX_UPLOAD=2000
REJECT_CALL=false
SUDO=989876543210
TZ=Asia/Kolkata
VPS=true
AUTO_STATUS_VIEW=false
SEND_READ=false
AJOIN=false
SESSION_ID="oussamabakrine"
EOL

echo "NAME=$BOT_NAME" >>config.env

if [ -n "$SESSION_ID" ]; then
    echo "SESSION_ID=$SESSION_ID" >>config.env
fi

echo -e "\e[33mStarting the bot...\e[0m"
pm2 start index.js --name "$BOT_NAME" --attach
