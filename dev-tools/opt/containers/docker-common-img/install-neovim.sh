#!/bin/bash - 
#===============================================================================
#
#          FILE: install-neovim.sh
# 
#         USAGE: /usr/bin/install-neovim.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: bill@azul3d.com
#  ORGANIZATION: 
#       CREATED: 07/30/24 13:56
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
set -e                                      # Exit immediately if a command exists 
                                            #  with a non-zero status
#
# For use in development only
#
if [ -d /opt ]; then
   echo "Error: /opt does not exist. Aborting..."
   exit 1
fi

cd /opt

if apt-get update && apt-get install -y gettext unzip build-essential xclip; then
    echo "Neovim APT commands succeeded."
else
    echo "Error: Neovim APT commands failed."
    exit 1  # Exit the script with a non-zero status
fi


# Clone Neovim repository
git clone --branch v0.10.1 https://github.com/neovim/neovim.git
cd neovim

# Run make with specified flags
if make CMAKE_EXTRA_FLAGS="-DENABLE_X11_CLIPBOARD=ON" \
           -DUSE_TREESITTER=ON \
           -DUSE_XDG=ON \
           -DENABLE_CLIENTSERVER=ON \
           -DUSE_MSGPACK=ON \
           CMAKE_BUILD_TYPE=Release; then
    echo "Neovim make succeeded."
else
    echo "Error: neovim make failed."
    exit 1  # Exit the script with a non-zero status
fi

# Install Neovim
if make install; then
    echo "Neovim installed successfully."
else
    echo "Error: Neovim installation failed."
    exit 1  # Exit the script with a non-zero status
fi

# Verify installation
nvim --version

