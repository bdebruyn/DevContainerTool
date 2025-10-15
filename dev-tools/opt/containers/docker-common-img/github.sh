#!/bin/bash - 
#===============================================================================
#
#          FILE: github.sh
# 
#         USAGE: ./github.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 12/30/21 08:26
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

GH_USER=$1
GH_REPO=$2
GH_BRANCH=$3

wget https://github.com/${GH_USER}/${GH_REPO}/archive/refs/tags/${GH_BRANCH}.tar.gz \
-O "${GH_REPO}-${GH_BRANCH}.tar.gz" && \
tar -xzvf ./"${GH_REPO}-${GH_BRANCH}.tar.gz" && \
rm ./"${GH_REPO}-${GH_BRANCH}.tar.gz"

