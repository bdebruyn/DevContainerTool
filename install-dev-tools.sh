#!/bin/bash
#===============================================================================
#
#          FILE: install-dev-tools.sh
# 
#         USAGE: install-dev-tools.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: billes.debruyn@gmail.com
#  ORGANIZATION: 
#       CREATED: 10/15/2025
#      REVISION:  ---
#===============================================================================

version="0.1.0-0"

echo "#==============================================================================="
echo "# Uninstalling previous version..."
echo "#==============================================================================="

dev-tools/uninstall.sh

echo "#==============================================================================="
echo "# Installing previous version..."
echo "#==============================================================================="

dev-tools/install.sh

