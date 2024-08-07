#!/bin/bash

# update the package manager
sudo xbps-install -Suy xbps

# setup doas
sudo xbps-install -y opendoas
sudo bash -c "echo 'permit nopass $USER as root' > /etc/doas.conf"

# update conflicted deps
doas xbps-install -yu util-linux
# install deps required for setup
doas xbps-install -y git rsync make gcc libX11-devel libXft-devel libXinerama-devel xorg-server xinit xauth xorg-fonts xorg-input-drivers pkg-config

mkdir ./.setup-void.temp
cd ./.setup-void.temp

git clone https://github.com/spirit-x64/dotfiles.git
git clone https://github.com/spirit-x64/dwm.git
git clone https://github.com/spirit-x64/dmenu.git
git clone https://github.com/spirit-x64/st.git

rsync -a --exclude='.git/' --exclude='LICENSE' dotfiles/ $HOME

cd dwm
doas make clean install

cd ../dmenu
doas make clean install

cd ../st
doas make clean install

echo 'exec dwm' > $HOME/.xinitrc

# system full-update
doas xbps-install -Suy
# install other packages i use
doas xbps-install -y patch wget curl vim firefox vscode juliaup yt-dlp tree

doas ln -s /usr/bin/julialauncher /usr/bin/julia

juliaup self update
juliaup add 1.0.0
juliaup add 1.10
juliaup add 1.11
juliaup default 1.10

# clean up
rm -fr ./.setup-void.temp/
