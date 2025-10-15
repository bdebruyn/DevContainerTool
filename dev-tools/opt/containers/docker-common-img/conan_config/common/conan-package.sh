#!/bin/bash - 
#===============================================================================
#
#          FILE: conan-package.sh
# 
#         USAGE: ./conan-package.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 09/23/20 16:43
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

arch=$(grep -m 1 "^[ ]*arch=" conaninfo.txt | cut -d'=' -f2)
echo "rm -rf ${arch}-package"
echo "conan package -pf ${arch}-package . "
rm -rf ${arch}-package
conan package -pf ${arch}-package . 
