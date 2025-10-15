#!/bin/bash

echo "#==============================================================================="
echo "# Checking .yaml file..."
echo "#==============================================================================="
echo ""

# Check if the YAML file is passed as an argument
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <config.yaml>"
    exit 1
fi

YAML_FILE=$1

# Check if pyyaml is installed, if not, install it
if ! python3 -c "import yaml" &> /dev/null; then
    pip install pyyaml || { echo "ERROR: Failed to install pyyaml"; exit 1; }
fi

echo "#==============================================================================="
echo "# Checking .yaml file for valid attributes..."
echo "#     Reporting any errors here:"
echo "#==============================================================================="
echo ""

# Run the Python script and capture its output in a bash variable
output=$(python3 -c "
import yaml
import sys

# Define valid values for each field
valid_ubuntu_versions = ['20.04', '22.04']
valid_processor_types = ['x86_64', 'ArmV8']
valid_yes_no = ['yes', 'no']

def readYamlConfig(filePath):
   with open(filePath, 'r') as file:
      config = yaml.safe_load(file)

   # Extract values
   ubuntuVersion = str(config.get('ubuntuVersion'))
   processorType = config.get('processorType')
   dockerImageName = config.get('dockerImageName')
   messageCGTool = config.get('messageCGToolBranchName')
   nvim = config.get('nvimBranchName')
   clearBase = config.get('clearBaseCache')
   clearDerived = config.get('clearDerivedCache')
   isLibcxxInstall = config.get('isLibcxxInstall')
   isYoctoInstall = config.get('isYoctoInstall')

   # Validate the values
   if ubuntuVersion not in valid_ubuntu_versions:
       sys.exit(f'Invalid Ubuntu Version: {ubuntuVersion}. Must be one of {valid_ubuntu_versions}')
   if processorType not in valid_processor_types:
       sys.exit(f'Invalid Processor Type: {processorType}. Must be one of {valid_processor_types}')
   if not dockerImageName:
       sys.exit('Docker Image Name is required.')
   if not messageCGTool:
       sys.exit('MessageCGTool Branch Name is required.')
   if not nvim:
       sys.exit('Nvim Branch Name is required.')
   if not isinstance(clearBase, bool):
       sys.exit('Clear Base Cache must be a boolean value.')
   if not isinstance(clearDerived, bool):
       sys.exit('Clear Derived Cache must be a boolean value.')
   if isLibcxxInstall not in valid_yes_no:
       sys.exit(f'Invalid value for isLibcxxInstall: {isLibcxxInstall}. Must be yes or no.')
   if isYoctoInstall not in valid_yes_no:
       sys.exit(f'Invalid value for isYoctoInstall: {isYoctoInstall}. Must be yes or no.')

   return [ubuntuVersion, processorType, dockerImageName, messageCGTool, nvim, clearBase, clearDerived, isLibcxxInstall, isYoctoInstall]

configList = readYamlConfig('$YAML_FILE')
print(','.join(map(str, configList)))
")

# Check if Python returned an error (non-zero exit code)
if [ $? -ne 0 ]; then
    echo ""
    echo "#==============================================================================="
    echo "# Yaml file has errors. Aborting..."
    echo "#==============================================================================="
    echo ""
    exit 1
fi

# Split the output into bash variables
IFS=',' read -r ubuntuVersion processorType dockerImageName messageCGTool nvim clearBase clearDerived isLibcxxInstall isYoctoInstall <<< "$output"

echo "#==============================================================================="
echo "# Parameter values are..."
echo "#==============================================================================="
echo ""
echo "    Ubuntu Version:       $ubuntuVersion"
echo "    Processor Type:       $processorType"
echo "    Docker Image Name:    $dockerImageName"
echo "    MessageCGTool Branch: $messageCGTool"
echo "    Nvim Branch:          $nvim"
echo "    Clear Base Cache:     $clearBase"
echo "    Clear Derived Cache:  $clearDerived"
echo "    Is libcxx installed:  $isLibcxxInstall"
echo "    Is Yocto  installed:  $isYoctoInstall"
echo ""

echo "#==============================================================================="
echo "# Checking if ~/dev-tools exits"
echo "#==============================================================================="
echo ""

if [ ! -d ~/dev-tools ]; then
   echo "Directory ~/dev-tools does not exist."
   echo "See instructions on how to install it. Aborting..."
   exit
fi

# Define source and destination paths
SOURCE_DIR=~/dev-tools
DEST_DIR=$(pwd)

SOURCE_HASH_FILE="$SOURCE_DIR/.hash"

# Step 1: Generate hash for the source if it doesn't have one
if [ ! -f "$SOURCE_HASH_FILE" ]; then
    echo "Generating hash for source directory..."

    if ! find "$SOURCE_DIR" -type f -exec sha256sum {} \; | sha256sum > "$SOURCE_HASH_FILE"; then
        echo "Error generating source hash."
        exit 1
    fi
fi

# Step 2: Check if destination directory exists
if [ ! -d "$DEST_DIR/dev-tools" ]; then
    echo "Destination directory does not exist. Creating and copying source..."
    mkdir -p "$DEST_DIR/dev-tools"
    echo ""
    echo "#==============================================================================="
    echo "# ~/dev-tools is newer. Copying files ..."
    echo "#==============================================================================="
    echo ""

    if ! rsync -a --delete "$SOURCE_DIR/" "$DEST_DIR/dev-tools"; then
        echo "Error copying source to destination."
        exit 1
    fi

    cp "$SOURCE_HASH_FILE" "$DEST_DIR/dev-tools/.hash"
    echo "Copy complete."
    echo ""
else
    # Step 3: Check for hash file in the destination
    DEST_HASH_FILE="$DEST_DIR/dev-tools/.hash"

    if [ ! -f "$DEST_HASH_FILE" ]; then
        echo "Destination hash file not found. Copying source to destination..."
        echo ""
        echo "#==============================================================================="
        echo "# ~/dev-tools is newer. Copying files ..."
        echo "#==============================================================================="
        echo ""

        if ! rsync -a --delete "$SOURCE_DIR/" "$DEST_DIR/dev-tools"; then
            echo "Error copying source to destination."
            exit 1
        fi

        cp "$SOURCE_HASH_FILE" "$DEST_DIR/dev-tools/.hash"
        echo "Copy complete."
        echo ""
    else
        # Step 4: Compare source and destination hashes
        echo "Comparing source and destination hashes..."
        SOURCE_HASH=$(cat "$SOURCE_HASH_FILE")
        DEST_HASH=$(cat "$DEST_HASH_FILE")

        if [ "$SOURCE_HASH" != "$DEST_HASH" ]; then
            echo "Hashes differ. Copying source to destination..."
            echo ""
            echo "#==============================================================================="
            echo "# ~/dev-tools is newer. Copying files ..."
            echo "#==============================================================================="
            echo ""

            if ! rsync -a --delete "$SOURCE_DIR/" "$DEST_DIR/dev-tools"; then
                echo "Error copying source to destination."
                exit 1
            fi

            cp "$SOURCE_HASH_FILE" "$DEST_DIR/dev-tools/.hash"
            echo "Copy complete."
            echo ""
        else
            echo ""
            echo "Hashes match. No copying needed."
            echo ""
        fi
    fi
fi


echo "#==============================================================================="
echo "# Using base image \"${dockerImageName}\""
echo "#==============================================================================="
echo ""

if [ -e "Dockerfile" ]; then
    rm -f Dockerfile
fi

if [ "$ubuntuVersion" == "20.04" ]; then
   ln -s docker-base-img/Dockerfile Dockerfile
   dockerBase="docker-base-img"

elif [ "$ubuntuVersion" == "22.04" ]; then
   ln -s docker-jammy-base-img/Dockerfile Dockerfile
   dockerBase="docker-jammy-base-img"

else
   echo " Error: \"${ubuntuVesion}\" not found. Aborting..."
   exit i
fi

echo ""
echo "#==============================================================================="
echo "# Building of \"${dockerBase}\" ..."
echo "#==============================================================================="
echo ""
base="ubuntu:${ubuntuVersion}"

docker build -t $dockerBase . --build-arg Base="$base"

rm -f Dockerfile

echo "#==============================================================================="
echo "# done building base image \"${dockerBase}\""
echo "#==============================================================================="
echo ""
echo "#==============================================================================="
echo "# initializing building of $processorType..."
echo "#==============================================================================="
echo ""

if [[   "$processorType" == "x86_64" && "$ubuntuVersion" == "20.04" ]]; then
   ln -s docker-x86_64-img/Dockerfile Dockerfile

elif [[ "$processorType" == "x86_64" && "$ubuntuVersion" == "22.04" ]]; then
   ln -s docker-jammy-x86_64-img/Dockerfile Dockerfile

elif [  "$processorType" == "ArmV8" ]; then
   ln -s docker-armv8-dunfell-img/Dockerfile Dockerfile

else
   echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
   echo "! ERROR: no docker file found for ${processorType}" running ${ubuntuVersion}
   echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
   exit 1
fi

echo "#==============================================================================="
echo "# building \"${dockerImageName}\" ..."
echo "#==============================================================================="

# Start the SSH agent if not already running
eval "$(ssh-agent -s)"
# Add your SSH key to the agent
ssh-add ~/.ssh/id_rsa

cacheArg=""

if [ "$clearDerived" = "True" ]; then
   cacheArg=" --no-cache"
   echo "cacheArg=\"${cacheArg}\""
fi

GID=""

if [[ "$(uname)" == "Darwin" ]]; then
   echo "Running on macOS"
elif [[ "$(uname)" == "Linux" ]]; then
   if [[ -f /etc/os-release ]]; then
      . /etc/os-release
      if [[ "$ID" == "ubuntu" ]]; then
         GID=$(getent group mad | cut -d: -f3)
         echo "Running on Ubuntu: GID=$GID"
      else
         echo "Running on another Linux distro: $ID"
      fi
   else
      echo "Running on generic Linux"
   fi
else
   echo "Unknown OS: $(uname)"
fi


docker build \
   ${cacheArg} \
   --ssh default \
   -t $dockerImageName \
   --build-arg Base="$dockerBase" \
   --build-arg UID="$(id -u)" \
   --build-arg GID="$GID" \
   --build-arg Name="$dockerImageName" \
   --build-arg MessageCGToolBranch="$messageCGTool" \
   --build-arg NvimBranch="$nvim" \
   --build-arg IsLibcxxInstall="$isLibcxxInstall" \
   --build-arg IsYoctoInstall="$isYoctoInstall" \
   .

rm -f Dockerfile

echo "#==============================================================================="
echo "# FINISHED building \"${dockerImageName}\" ..."
echo "#==============================================================================="

