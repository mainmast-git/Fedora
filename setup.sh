#!/bin/bash

echo "Starting Fedora Post-Installation Setup..."

# Update & Upgrade System
echo "Updating and upgrading the system..."
sudo dnf update -y && sudo dnf upgrade -y && flatpak update -y

# Enable free & nonfree repositories
echo "Enabling free and nonfree repositories..."
sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf update -y

# Install APT Packages
echo "Installing required packages..."
sudo dnf install -y \
    vim @virtualization bridge-utils timeshift neovim \
    qdirstat qt5ct gns3-gui gns3-server libxcb-xinerama0 \
    tldr fastfetch lsd make gawk trash-cli fzf bash-completion \
    whois bat tree ripgrep gnome-tweaks plocate fail2ban \
    fastfetch gns3-iou papirus-icon-theme epapirus-icon-theme \
    google-chrome-stable
 

echo "Installing Flatpak apps..."
flatpak install -y flathub com.rustdesk.RustDesk com.usebottles.bottles com.spotify.Client io.github.shiftey.Desktop io.missioncenter.MissionCenter com.obsproject.Studio
flatpak install --user -y https://sober.vinegarhq.org/sober.flatpakref

# Install .rpm Packages
echo "Downloading and installing TeamViewer..."
wget -O /tmp/teamviewer.rpm https://download.teamviewer.com/download/linux/teamviewer.x86_64.rpm
sudo dnf install -y /tmp/teamviewer.rpm

# Setup qt5ct theme for KDE applications
echo "Setting up theme (Fusion + GTK3 + darker) for KDE..."
qt5ct # For user
sudo qt5ct # For super user 

# Set Dark Mode in GNOME
echo "Configuring GNOME theme..."
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

# Pin favorite apps to the Fedora dock
gsettings set org.gnome.shell favorite-apps "$(gsettings get org.gnome.shell favorite-apps | sed "s/]$/, 'google-chrome.desktop']/")"
gsettings set org.gnome.shell favorite-apps "$(gsettings get org.gnome.shell favorite-apps | sed "s/]$/, 'com.spotify.Client.desktop']/")"
gsettings set org.gnome.shell favorite-apps "$(gsettings get org.gnome.shell favorite-apps | sed "s/]$/, 'gns3.desktop']/")"

# Unpin favorite apps from the Fedora dock
gsettings set org.gnome.shell favorite-apps "$(gsettings get org.gnome.shell favorite-apps | sed "s/, 'firefox_firefox.desktop'//" | sed "s/'firefox_firefox.desktop', //")"

# Remove apps I don't need
sudo dnf remove -y firefox

# Clone your Fedora repo
echo "Cloning configuration repository..."
git clone https://github.com/ramin-samadi/Fedora.git /tmp/Fedora
git clone https://github.com/orangci/walls-catppuccin-mocha.git ~/Wallpapers
sudo mv /tmp/Fedora/usr/local/bin/change_wallpaper.sh /usr/local/bin/

# Copy configuration files
echo "Deploying user configurations..."
sudo mv -f /tmp/Fedora/home/.config/* $HOME/.config/
sudo mv -f /tmp/Fedora/home/.vimrc $HOME/

# Enable firewall + Fail2Ban
sudo ufw enable
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo systemctl enable fail2ban

# Add custom configuration to .bashrc
git clone --depth=1 https://github.com/ChrisTitusTech/mybash.git ~/mybash
chmod +x ~/mybash/setup.sh
~/mybash/setup.sh
git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git
make -C ble.sh install PREFIX=~/.local
echo 'source ~/.local/share/blesh/ble.sh' >> ~/.bashrc
cat << EOF >> ~/.bashrc
alias qdirstat='nohup sudo -E qdirstat'
export QT_QPA_PLATFORMTHEME=qt5ct
alias edit='nvim'
alias sedit='sudo nvim'
alias clear='clear; fastfetch'
alias cls='clear'
bind -x '"\C-l": clear'
alias update='sudo dnf update -y; sudo dnf upgrade -y; flatpak update -y; sudo snap refresh'
alias install='sudo dnf install -y'
alias search='dnf search'
alias uninstall='sudo dnf remove -y'
alias clean='sudo dnf autoremove -y && sudo dnf autoclean -y'
alias packages='dnf list --installed'
alias ping='ping -c 4'
alias ip='ip -c'
alias vi='\vi'
alias ?='tldr'
alias explain='tldr'
alias ~='cd $HOME'
alias -- -="cd -"
# Alias's for multiple directory listing commands
alias la='lsd -Alh'                # show hidden files
alias ls='lsd -aFh --color=always' # add colors and file type extension
alias lx='lsd -lXBh'               # sort by extension
alias lk='lsd -lSrh'               # sort by size
alias lc='lsd -ltcrh'              # sort by change time
alias lu='lsd -lturh'              # sort by access time
alias lr='lsd -lRh'                # recursive ls
alias lt='lsd -ltrh'               # sort by date
alias lm='lsd -alh |more'          # pipe through 'more'
alias lw='lsd -xAh'                # wide listing format
alias ll='lsd -Fl'                 # long listing format
alias labc='lsd -lap'              # alphabetical sort
alias lf="lsd -l | egrep -v '^d'"  # files only
alias ldir="lsd -l | egrep '^d'"   # directories only
alias lla='lsd -Al'                # List and Hidden Files
alias las='lsd -A'                 # Hidden Files
alias lls='lsd -l'                 # List
alias serial-number='sudo dmidecode -s system-serial-number'
alias bios-version='sudo dmidecode -s bios-version'
alias uefi='sudo systemctl reboot --firmware-setup'
EOF

# Set catppuccin mocha theme

## Set font to MesloLGS Nerd Font
gsettings set org.gnome.desktop.interface monospace-font-name 'MesloLGS Nerd Font 12'

## bat
mkdir -p "$(bat --config-dir)/themes"
wget -P "$(bat --config-dir)/themes" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Latte.tmTheme
wget -P "$(bat --config-dir)/themes" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Frappe.tmTheme
wget -P "$(bat --config-dir)/themes" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Macchiato.tmTheme
wget -P "$(bat --config-dir)/themes" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Mocha.tmTheme
bat cache --build

## Papirus icons
git clone https://github.com/catppuccin/papirus-folders.git
cd papirus-folders
sudo cp -r src/* /usr/share/icons/Papirus
curl -LO https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-folders/master/papirus-folders && chmod +x ./papirus-folders
./papirus-folders -C cat-mocha-lavender --theme Papirus-Dark
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'

## GTK 3/4 theming
cd $HOME
curl -LsSO "https://raw.githubusercontent.com/catppuccin/gtk/v1.0.3/install.py"
python3 install.py mocha lavender
gsettings set org.gnome.desktop.interface gtk-theme 'catppuccin-mocha-lavender-standard+default'

# Reload .bashrc
source ~/.bashrc

# Clean up
echo "Removing cloned repository..."
rm -rf /tmp/Fedora

echo "Cleaning up downloaded .rpm files..."
rm /tmp/google-chrome.rpm /tmp/teamviewer.rpm 

# Install GNS3 for Fedora and reboot after completed install
git clone https://github.com/ramin-samadi/FedoraGNS3.git /tmp/FedoraGNS3
/tmp/FedoraGNS3/scripts/install.sh
