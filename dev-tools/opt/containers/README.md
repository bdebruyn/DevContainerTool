# dev-tools

## Contents
- [Build and Test using Vim](docs/VimTools.md)
- [Azul3D Standard CMake Funtions](docs/Azul3DStandardCMakeFunctions.md)

## Overview

This repo contains the logic for building Azul3D docker images and the tools for running them.

The following tools are described here:

1. Azul3DConan.py
2. azul3d-img

## Azul3DConan.py

The Azul3DConan class becomes the new base class for any conanfile.py.   

```python
#!/usr/bin/python
from Azul3DConan import Azul3DConan

class DataStreamerConan(Azul3DConan):
    name = "data-streamer"
    version = "0.0.1"

    def requirements(self):
        # WARNNING! DO NOT REMOVE! Beginning of Protected Section
        self.preRequirements(self)
        # WARNNING! DO NOT REMOVE! End of Protected Section

    def imports(self):
        self.build_folder = self.getBuildFolder()
        self.symbolicLinkCompileCommands()

    def buildOptions(self, cmake):
        cmake.definitions['NICE_SCHED'] = True

    def package(self):
        # WARNNING! DO NOT REMOVE! Beginning of Protected Section
        self.prePackage()
        # WARNNING! DO NOT REMOVE! End of Protected Section


```

Both the `requirements` and the `package` methods require an initial call to the Azul3DConan base class.

The `imports` method is optional and performs exactly as Conan describes it.

The `buildOptions` method is optional. It allows the user to make changes to cmake and any build options.

## Docker Image Tool

Two Docker images are supported: X86_64 and Armv8 architectures.

### Building the Docker Images

#### x86_64
```bash
$ ./build-cpp-img.sh
```
#### Armv8
```bash
$ ./build-yocto-img.sh
```

## azul3d-img Tool

The azul3d-img tool creates and manages docker containers used by Azul3D software developers.

### Installation

```bash
$ cd ~/Project/git
$ git clone git@github.com:CDJ-Technologies/dev-tools.git
$ vim ~/.bashrc
export PATH=~/Project/git/dev-tools/container-manager:$PATH
```
Of course where you install the dev-tools is up to you. Just make sure the path is set accordingly.

### Managing Dependent Repos

Once you have successfully created the container and the branch (see instructions below), it's time to put the tools to use. Start by clone the application or library of interest. We shall refer to the repo as the `end point`.
```bash
$ cd <repo>
$ conan_source
```
Conan will recursively clone the `requires` dependent repos into the container, checkout the branch, build and copy to the cache.

NOTE: When checking out a repo from `gitlab` you may be required to affirm the ssh connection with a `yes`.

### Building Dependent Repos

This command will perform a build on the current repo and all of its dependent repos.

```bash
$ cd <repo>
$ conan_rebuild_source
```

### Selectively Rebuilding Repos

The list of built dependent repos is stored in a file `/tmp/RepoVisits.txt`. You may edit the file to add or remove repos from the list and rerun the `conan_source` command. Any repo encountered during the traversing of the dependent repos that is not in the stored file will be build and the repo name added to the file.

### Configuring the YAML file
An example of the configuration file can be found under the dev-tools/container-manager/sample.yaml. Copy and rename the file to any location on your file system.

The following  parameters are currently supported:

#### integration:
The name of the integration branch currently where code changes are merged back to.

###### Note: legal characters in the branch name are `[a-zA-Z0-9-_]*`. No `#` allowed.

#### branch:
The name of the development branch you want to use to make changes. This branch will be branched from the integration branch.

###### Note: legal characters in the branch name are `[a-zA-Z0-9-_]*`. No `#` allowed.

#### profile:

The set of bash alias for installing conan profiles

#### container:

The name of the container. This will show up in the `docker ps -a` command under the `name` heading.

#### image:

The name of the image used to instantiate the container. Currently, the legal values are `cpp-img` and `yocto-img`

#### root:

The relative or absolute path to where you want to keep the Conan cache. The cache can be located anywhere on your file system.

### Sample.YAML

```bash
integration: release-0.2
branch: test-55
profile: install-debug.sh
container: test-55
image: cpp-img
root: /home/bill/Project/test-55
```

### Creating a Container

```bash
$ cd ~
$ azul3d-img -f ~/Project/issue-55.yaml
```
A directory will be created frum the `root` parameter, which in the sample.yaml will be `~/Project/test-55`. A container will be created and named after the `container` parameter. The docker image used to instantiate the container is taken from the parameter `image`. If everything is successful, you will land inside the container.

### Environment Variables

##### BRANCH_INT
The integration branch name is kept in this variable. It is copied from the yaml parameter: `integration`. Future tools may use this variable to perform branch checkouts based on the integration branch.

##### BRANCH_DEV
The development branch name is kept in this variable. It is copied from the yaml parameter: `branch`. Future tools may use this variable to perform branch checkouts off of the integration branch.

##### CONAN_PROFILE
The conan profile alias used to install a conan profile. See the ~/.conan/tools directory for the types of profiles supported.

##### CONTAINER_NAME
Useful if you have many different containers open and you want to verify you're working in the right container.

##### IMAGE_NAME
Useful if you want to know whether you're working out of `cpp-img` or `yocto-img`.

##### CACHE_LOCATION
Useful if you want to know where the container files are currently located. This can help transfer files in and out of the container or help manage the Conan cache.

### Remove a container

```bash
$ azul3d-img -k test-55
```
Where `test-55` is the name of the container found inside the yaml files
