#!/bin/bash - 
#===============================================================================
#
#          FILE:  new-branch-for-all.sh
# 
#         USAGE:  ./new-branch-for-all.sh <base-branch> <new-branch>
# 
#   DESCRIPTION:  pushes new branch to all repositories in container
#                 new branch is specified in the .yaml file
# 
#       OPTIONS:
#  REQUIREMENTS:  user must have access to Azul3D github
#          BUGS:
#         NOTES:
#        AUTHOR:  smikell 
#  ORGANIZATION:  Azul3D
#       CREATED:  08/24/22 10:33
#      REVISION:  03/27/23 10:47
#===============================================================================

set -o nounset                              # Treat unset variables as an error

if [ $# -ne 2 ]; then
   echo "USAGE: ./new-branch-for-all.sh <base-branch> <new-branch>"
   exit 1
fi

git_dir="azulBranchUpdate"
base_branch=$1
new_branch=$2

repos=(
	"ArmV8Deployment"
	"AutoAlignment"
	"CommonApplication"
	"ConsolePlatform"
	"DartPeripherals"
	"DataRepositoryContracts"
	"Deployment"
	"FluidsController"
	"Framework"
	"MessageContractTools"
	"MessageContracts"
	"PreprocessController"
	"PrintJobController"
	"PrinterLogger"
	"PrinterNetworkFramework"
	"ProjectorController"
	"StewartMathEngine"
	"X86Deployment"
	"ZArmController"
	"alignment-opencv"
	"g3log"
	"g3logrotate"
	"mosquittov2"
	"spinnaker"
	"teknic"
	"IntegrationTesting"
	"AzulFrontend"
	"UEPlugin"
)

newBranchForAll() {
	for repo in ${repos[@]}; do
		git clone git@github.com:CDJ-Technologies/${repo}.git
	done

	for repoDir in *; do
		if [ -d ${repoDir} ]; then
			(cd ${repoDir}; git checkout ${base_branch})
			(cd ${repoDir}; git checkout -b ${new_branch})
			(cd ${repoDir}; git push origin ${new_branch})
		fi
	done
}

mkdir ~/${git_dir}

(cd ~/${git_dir}; newBranchForAll)

rm -rf ~/${git_dir}
