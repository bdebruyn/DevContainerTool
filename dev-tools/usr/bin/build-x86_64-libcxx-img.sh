#!/bin/bash - 
#===============================================================================
#
#          FILE: build-x86_64-libcxx-img.sh
# 
#         USAGE: ./build-x86_64-libcxx-img.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: znicholas@azul3d.com
#  ORGANIZATION: 
#       CREATED: 2/14/23 09:33
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

img="x86_64-libcxx-img"

cd /opt/containers/docker-common-img; ./build-azul3d-img.sh $img
