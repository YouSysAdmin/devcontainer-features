set -e

USERNAME=${USERNAME:-"automatic"}

apt-get update -y
apt-get -y install --no-install-recommends libssl-dev libreadline-dev zlib1g-dev autoconf bison build-essential \
  libyaml-dev libreadline-dev libncurses5-dev libffi-dev libgdbm-dev libxml2-dev rustc \
  libmariadb-dev-compat libmariadb-dev libjemalloc-dev

su -l "${USERNAME}" -c "git clone https://github.com/rbenv/rbenv.git /home/${USERNAME}/.rbenv"
su -l "${USERNAME}" -c "git clone https://github.com/rbenv/ruby-build.git /home/${USERNAME}/.rbenv/plugins/ruby-build"

# Add RBEnv init to systemd profile - sh, bash
sudo tee -a /etc/profile.d/rbenv.sh <<'EOF'
if [ -d "$HOME/.rbenv" ]; then
  export PATH=$HOME/.rbenv/bin:$PATH;
  export RBENV_ROOT=$HOME/.rbenv;
  eval "$(rbenv init -)";
fi
EOF

# Add RBEnv init to systemd profile - zsh
sudo tee -a /etc/zsh/zprofile <<'EOF'
if [ -d "$HOME/.rbenv" ]; then
  export PATH=$HOME/.rbenv/bin:$PATH;
  export RBENV_ROOT=$HOME/.rbenv;
  eval "$(rbenv init -)";
fi
EOF

chmod +x /etc/profile.d/rbenv.sh

su -l "${USERNAME}" -c "RUBY_CONFIGURE_OPTS='--with-jemalloc' /home/${USERNAME}/.rbenv/bin/rbenv install ${VERSION}"
su -l "${USERNAME}" -c "/home/${USERNAME}/.rbenv/bin/rbenv global ${VERSION}"

rm -rf /var/lib/apt/lists/*
