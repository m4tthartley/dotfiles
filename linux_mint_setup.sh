
# This is the repo for wezterm
curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
sudo chmod 644 /usr/share/keyrings/wezterm-fury.gpg

# This is the repo for vscodium
wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg | gpg --dearmor | sudo dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg
echo -e 'Types: deb\nURIs: https://download.vscodium.com/debs\nSuites: vscodium\nComponents: main\nArchitectures: amd64 arm64\nSigned-by: /usr/share/keyrings/vscodium-archive-keyring.gpg' | sudo tee /etc/apt/sources.list.d/vscodium.sources

# This is the repo for yt-dlp
sudo add-apt-repository ppa:tomtomtom/yt-dlp

# This is the repo for sublime text
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo tee /etc/apt/keyrings/sublimehq-pub.asc > /dev/null
echo -e 'Types: deb\nURIs: https://download.sublimetext.com/\nSuites: apt/stable/\nSigned-By: /etc/apt/keyrings/sublimehq-pub.asc' | sudo tee /etc/apt/sources.list.d/sublime-text.sources


sudo apt update

# Install general packages
sudo apt install git --yes
sudo apt install stow -y
sudo apt install vim -y
sudo apt install wezterm -y
# flatpak install flathub org.wezfurlong.wezterm -y
flatpak install flathub com.google.Chrome -y
sudo apt install ffmpeg -y
flatpak install flathub com.makemkv.MakeMKV -y
sudo apt install mkvtoolnix -y
sudo apt install codium -y
sudo apt install build-essential -y
sudo apt install clang -y
sudo apt install lldb -y
sudo apt install clangd -y
sudo apt install libgl-dev -y
sudo apt install qbittorrent -y
sudo apt install btop -y
sudo apt install yt-dlp
flatpak install flathub net.blockbench.Blockbench
flatpak install flathub com.github.libresprite.LibreSprite
flatpak install flathub com.github.PintaProject.Pinta
flatpak install flathub com.discordapp.Discord

# Install video editing packages
sudo apt install obs -y
sudo apt install audacity -y
# Install Davinci Resolve with MakeResolveDeb:
# https://www.danieltufvesson.com/makeresolvedeb

# i3
sudo apt install i3 -y
sudo apt install picom -y
sudo apt install rofi -y
sudo apt install polybar -y
sudo apt install feh -y

# Install JetBrainsMono font
#/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/JetBrains/JetBrainsMono/master/install_manual.sh)"
wget -P ~/.local/share/fonts https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip
cd ~/.local/share/fonts
unzip JetBrainsMono.zip
rm JetBrainsMono.zip
fc-cache -fv
cd ~

# Gaming
sudo apt install steam -y
# maybe sudo apt install nvidia-driver-libs:i386 -y
sudo apt install lutris -y

# NordVPN
sh <(wget -qO - https://downloads.nordcdn.com/apps/linux/install.sh) -p nordvpn-gui
sudo groupadd nordvpn
sudo usermod -aG nordvpn $USER

# Music
sudo apt install asunder -y
sudo apt install rhythmbox -y
sudo apt install clementine -y


