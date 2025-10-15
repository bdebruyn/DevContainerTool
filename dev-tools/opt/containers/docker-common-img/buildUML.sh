#!/bin/bash - 
#===============================================================================
#
#          FILE: buildUML.sh
# 
#         USAGE: ./buildUML.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 01/07/22 11:49
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

java -jar /usr/bin/plantuml.jar -tpng -o../png $0

