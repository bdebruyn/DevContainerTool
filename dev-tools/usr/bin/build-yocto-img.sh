#!/bin/bash - 
#===============================================================================
#
#          FILE: build-yocto-img.sh
# 
#         USAGE: ./build-yocto-img.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: znicholas@azul3d.com
#  ORGANIZATION: 
#       CREATED: 1/12/23 10:36AM
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

img="yocto-img"

cd /opt/containers/docker-common-img; ./build-azul3d-img.sh $img
