set -e

USERNAME=${USERNAME:-"dev"}

apt-get update -y
apt-get -y install --no-install-recommends neovim

su -l "${USERNAME}" -c "mkdir -p /home/${USERNAME}/.config"
su -l "${USERNAME}" -c "cp -r $PWD/nvim /home/${USERNAME}/.config/nvim"

rm -rf /var/lib/apt/lists/*
