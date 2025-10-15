# dev-tools

This tool provides much of the boilerplate functionality required to stand up 
a docker container for developing code

## Latest Installation Instructions

The biggest change is 
1. Remove all docker containers by running this command `remove-all-containers`

2. Remove all docker images by running this command `remove-all-docker-images`.   <b>NOTICE: ALL IMAGES WILL BE REMOVED</b>

3. Run `sudo install-dev-tools.sh`.

NOTE: The debian tool is no longer used to perform the installation. Symbolic links now link files and directories in the root space to files and directories int the git repo space. Installation is quick and easy. Updates made in the repo are automatically reflected in the root space.

### Under the Hood

1. The tool perform an uninstall of the previous version by unlinking files and directories between the root and user space.
2. The command `sudo ./dev-tools/uninstall.sh` is run by `install-dev-tools.sh`

The install the new tools is performed by running the command `sudo ./dev-tools/install.sh`

### Directory Layout

```
├── dev-tools
│   ├── install.sh
│   ├── uninstall.sh
│   ├── DEBIAN
│   │   └── control
│   ├── nvidia
│   │   └── install-nvidia-container-toolkit.sh
│   ├── opt
│   │   └── containers
│   │       ├── container-manager
│   │       ├── docker-common-img
│   │       ├── docs
│   │       ├── README.md
│   │       └── tools
│   └── usr
│       └── bin
│           ├── assh
│           ├── azul3d-img
│           ├── build-armv8-dunfell-img.sh
│           ├── build-x86_64-img.sh
│           ├── build-x86_64-libcxx-img.sh
│           ├── build-yocto-img.sh
│           ├── calcSha256.sh
│           ├── fetchLatestImage.sh
│           ├── ip-masquerading.sh
│           ├── new-branch-for-all.sh
│           ├── remove-all-containers
│           ├── remove-all-docker-images
│           └── switch-test.sh
├── install-dev-tools.sh
└── README.md
```

Tab completion in the shell is usually handled by bash-completion package. If tab completion is not working for symbolic links, there are a few things you can check or try to fix the issue:

Ensure bash-completion is installed:
Make sure you have the bash-completion package installed. You can install it using:

```bash
sudo apt update
sudo apt install bash-completion
```

Check if bash-completion is enabled:
Ensure that bash-completion is sourced in your .bashrc or .bash_profile. You can add the following lines to your .bashrc:

```bash
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi
```

After adding this, reload your .bashrc:

```bash
source ~/.bashrc
```

# Jammy (Ubuntu 22.04)

Jammy requires a stronger encryption. Using the old RSA key generation will not work with TCP. It includes `ssh`, `mqtt`, `tcp` and so on.

The temporary workaround is

```bash
sudo vim /etc/ssh/ssh_config
```

Add the following options
```bash
Host *
    # ... other options ...
    HostKeyAlgorithms +ssh-rsa
    PubkeyAcceptedKeyTypes +ssh-rsa
    # ... other options ...
    IdentityFile ~/.ssh/id_rsa
```

Test the fix using
```bash
ssh root@192.168.10.10
```

This is just a temporary fix until you have regenerated your encryption key with a stronger key with sites like github.

# Installation

## NVIDIA-RTX-3070-TI Install

```bash
$ apt search nvida-driver
$ sudo apt update
$ sudo apt upgrade
$ sudo apt install [driver-name]
```
Example is Linux kernel version 5.15.0-84. The `driver-name` is `nvidia-driver-525`, You may have to uninstall and install it again. If you get a blank screen after boot, use `ctrl` + `alt` + `F2` to get into terminal mode.
