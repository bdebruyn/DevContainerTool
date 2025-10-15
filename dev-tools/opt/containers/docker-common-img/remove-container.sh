#!/bin/bash - 
#===============================================================================
#
#          FILE: remove-containers.sh
# 
#         USAGE: ./remove-containers.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: bill@azul3d.com
#  ORGANIZATION: 
#       CREATED: 08/13/2021 18:01
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

if [ "$#" -ne 1 ]; then
   echo "ERROR: missing parameter. Need docker image name"
   exit 1
fi

docker ps |grep "$1" | cut -d' ' -f1 |xargs docker kill 
