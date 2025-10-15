#!/bin/bash - 
#===============================================================================
#
#          FILE: install-nvim-dev-env.sh
# 
#         USAGE: /usr/bin/install-nvim-dev-env.sh 
# 
#   DESCRIPTION: 
#           Copy this script to the /usr/bin directory. 
#           Objective is to enable developers to work in plugin development
#           This file should be installed in the container during build
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: billes.debruyn@gmail.com
#  ORGANIZATION: 
#       CREATED: 09/23/25
#      REVISION:  ---
#===============================================================================

#===============================================================================
# Prebuild ready to install nvim linux64
# https://sourceforge.net/projects/neovim.mirror/files/stable/nvim-linux64.tar.gz/download
#
#===============================================================================

set -o nounset                              # Treat unset variables as an error
set -e                                      # Exit immediately if a command exists 
                                            #  with a non-zero status
#
# For use in development only
#
# if [ -d "/repo" ]; then
#    echo "/repo exists"
# else
#    echo "Error: /repo does not exist. Aborting..."
#    exit 1
# fi

#
# Define directories and repository URLs
#
GP_REPO_DIR="/repo/gp.nvim"
GP_GIT_URL="git@github.com:CDJ-Technologies/gp.nvim.git"

NVIM_DEV_TOOLS_REPO_DIR="/repo/nvim-dev-tools"
NVIM_DEV_TOOLS_GIT_URL="git@github.com:CDJ-Technologies/nvim-dev-tools.git"

CLONE_DIR="/repo"

# Function to check if directory exists and clone if not
clone_repo_if_needed() {
    local REPO_DIR=$1
    local GIT_URL=$2
    
    # if [ -d "$REPO_DIR" ]; then
    #     echo "Directory $REPO_DIR already exists."
    # else
        echo "Directory $REPO_DIR does not exist. Cloning repository..."
        
        # Clone the repository
        git clone "$GIT_URL" "$CLONE_DIR"
        
        # # Check if the clone was successful
        # if [ $? -eq 0 ]; then
        #     echo "Repository cloned successfully."
        # else
        #     echo "Error: Failed to clone repository. Aborting..."
        #     exit 1
        # fi
    # fi
}

#
# Check and clone gp.nvim if needed
#
clone_repo_if_needed "$GP_REPO_DIR" "$GP_GIT_URL"

#
# Check and clone nvim-dev-tools if needed
#
clone_repo_if_needed "$NVIM_DEV_TOOLS_REPO_DIR" "$NVIM_DEV_TOOLS_GIT_URL"

# 
# In the home config space, create a soft link to the nvim repo located at /repo/nvim-dev-tools
#

echo "### Creating soft link from ~/.config/nvim to /repo/nvim-dev-tools/nvim ###"
cd ~
mkdir -p .config
cd .config
ln -s /repo/nvim-dev-tools/nvim nvim
echo "### Created soft link from ~/.config/nvim to /repo/nvim-dev-tools/nvim ###"

#
# install luarocks and pynvim (python interface) and busted (test framework)
#
echo "### Installing nvim tools for unit testing ###"
sudo apt update && sudo apt install -y python3-pip luarocks
pip3 install pynvim
sudo luarocks install busted
busted --version
echo "### Installed nvim tools for unit testing ###"

#
# install Packer for nvim plugins
#
echo "### Installing Packer plugin manager ###"
git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim
echo "### Installed Packer plugin manager ###"

#
# In the home config space, create a soft link to the gp.nvim plugin at /repo/gp.nvim
# Make sure it is cloned first.
#
echo "### Creating soft link from ~/.config/nvim/local_plugins /repo/gp.nvim ###"
mkdir -p  ~/.config/nvim/local_plugins
rm -rf  ~/.config/nvim/local_plugins/gp.nvim
ln -s  /repo/gp.nvim ~/.config/nvim/local_plugins/gp.nvim
echo "### Created soft link from ~/.config/nvim/local_plugins /repo/gp.nvim ###"

#
# Run PackerSync from the command line
#
echo "### Running PackSync ###"
nvim -c 'PackerInstall | qa'
echo "### Ran PackSync ###"

echo "+++++++++++++++++DONE+++++++++++++++++++"
