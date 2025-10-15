# syntax=docker/dockerfile:1.4

ARG Base

FROM ${Base}

ARG UID
ARG GID
ARG Name
ARG MessageCGToolBranch
ARG NvimBranch
ARG IsLibcxxInstall
ARG IsYoctoInstall

# Upgrade system and Yocto Project basic dependencies
RUN apt-get -y update && apt-get -y upgrade && DEBIAN_FRONTEND="noninteractive" apt-get -y install \
    gawk \
    git-core \
    diffstat \
    unzip \
    texinfo \
    chrpath \
    socat \
    cpio \
    xz-utils \
    debianutils \
    iputils-ping \
    libsdl1.2-dev \
    xterm \
    autoconf \
    libglib2.0-dev \
    libarchive-dev \
    sed \
    cvs \
    coreutils \
    texi2html \
    docbook-utils \
    help2man \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    mercurial \
    groff \
    lzop \
    asciidoc \
    u-boot-tools \
    dos2unix \
    mtd-utils pv \
    libncurses5 \
    libelf-dev \
    zlib1g-dev \
    bc \
   rsync
   
RUN if [ "$IsYoctoInstall" = "yes" ]; then \
        apt-get -y update && apt-get -y upgrade && DEBIAN_FRONTEND="noninteractive" apt-get -y install \
            python-git-doc \
            python \
            python3-pexpect \
            python-pysqlite2; \
    fi
   
################################ Install Yocto ################################################
# Copy Variscite Linux kernel to container
#
COPY dev-tools/linux-imx-54.2-1.x-imx_var01.tar.gz .
RUN mkdir -p /lib/modules/5.4.142/build && tar xf linux-imx-54.2-1.x-imx_var01.tar.gz && cp -r linux-imx/* /lib/modules/5.4.142/build/

COPY dev-tools/fslc-xwayland-glibc-x86_64-fsl-image-gui-aarch64-imx8mq-var-dart-toolchain-3.1.sh .
RUN if [ "$IsYoctoInstall" = "yes" ]; then \
        chmod +x fslc-xwayland-glibc-x86_64-fsl-image-gui-aarch64-imx8mq-var-dart-toolchain-3.1.sh; \
        printf '/opt/yocto\ny\n' |  ./fslc-xwayland-glibc-x86_64-fsl-image-gui-aarch64-imx8mq-var-dart-toolchain-3.1.sh; \
        rm fslc-xwayland-glibc-x86_64-fsl-image-gui-aarch64-imx8mq-var-dart-toolchain-3.1.sh; \
    fi 
#
#################################

###### --- install mosquitto support --- #####
#
WORKDIR /etc/mosquitto
COPY etc/mosquitto/mosquitto_armv8.conf mosquitto.conf
#
#################################

###### --- install openssh-client, epiphany browser, tree, tmux and opencl --- #####
#
RUN apt-get --yes update && DEBIAN_FRONTEND="noninteractive" apt-get --yes install openssh-client epiphany-browser tree tmux clinfo
#
#################################


###### --- install locales --- #####
#
RUN set -xe; \
     apt update; \
     DEBIAN_FRONTEND="noninteractive" apt-get -y install locales apt-utils sudo && rm -rf /var/lib/apt/lists/*; \
     dpkg-reconfigure locales; \
     locale-gen en_US.UTF-8 ; \
     update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8;
ENV LANG=en_US.utf8
#
#################################

###### --- install nvim --- #####
#
#  precompiled version copied to bin, lib and share directories
#
WORKDIR /opt
RUN apt-get update && apt-get install -y gettext unzip xclip  && rm -rf /var/lib/apt/lists/*
COPY dev-tools/nvim-linux64.tar.gz .
RUN  tar -xf nvim-linux64.tar.gz && \
     cp -r nvim-linux64/bin/*   /usr/local/bin && \
     cp -r nvim-linux64/lib/*   /usr/local/lib && \
     cp -r nvim-linux64/share/* /usr/local/share
#
#################################

###### -- remove all tool conflicts with SDK ################################################
#
RUN if [ "$IsYoctoInstall" = "yes" ]; then \
        sudo rm /opt/yocto/sysroots/x86_64-fslcsdk-linux//usr/bin/python3; \
    fi
#
##############################################################################################

##############################################################################################
#
#  Installing User
#
##############################################################################################

###### --- install user --- #####
#
RUN apt-get -y update && apt-get -y install xterm sudo && \
  DEBIAN_FRONTEND=noninteractive apt-get clean && rm -rf /var/lib/apt/lists/*

RUN echo "    IdentityFile ~/.ssh/id_rsa" >> /etc/ssh/ssh_config

RUN groupadd -g $GID ubuntu
RUN useradd -rm -d /home/ubuntu -s /bin/bash -g $UID -G sudo -u $GID ubuntu

RUN echo "ubuntu ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER ubuntu
WORKDIR /home/ubuntu
COPY .bashrc .bashrc
RUN sudo chown ubuntu .bashrc
ENV PATH="/home/ubuntu/.conan/tools:$PATH"
#
#################################

###### --- install .bash_profile --- #####
#
USER ubuntu
RUN echo "if [ -o interactive ] && [ -f ~/.bashrc ]; then\n \tsource ~/.bashrc\n fi" >> .bash_profile
#
#################################

####### --- setup security -- #################
# 
USER ubuntu
WORKDIR /home/ubuntu

RUN mkdir -p /home/ubuntu/.ssh && \
    ssh-keyscan github.com >> /home/ubuntu/.ssh/known_hosts && \
    chmod 700 /home/ubuntu/.ssh && \
    chmod 644 /home/ubuntu/.ssh/known_hosts
#
#################################

###### --- install support for neovim --- #####
#
RUN sudo apt-get update && sudo apt-get install -y python3-pip luarocks
RUN pip3 install pynvim
RUN sudo luarocks install busted
#
###

###### --- install valgrind --- #####
#
# Support valgrind false positive error suppression
#
COPY valgrind.tar.xz .
RUN set -xe; \
    tar xf valgrind.tar.xz; \
    cp valgrind/.valgrindrc .; \
    cp valgrind/opengl.supp .; \
    rm valgrind.tar.xz;
#
#################################

###### --- install vim --- #####
#
# git clone https://github.com/VundleVim/Vundle.vim.git .vim/bundle/Vundle.vim; \
#
COPY .vimrc .
COPY Vundle.vim/ .vim/bundle/Vundle.vim/

RUN set -xe; \
    mkdir -p /home/ubuntu/.vim-tmp; \
    sudo chown -R ubuntu .vim; \
    vim -c 'PluginInstall' -c 'qa!'; \
    cd .vim/bundle/YouCompleteMe; \
    python3 install.py --clangd-completer;
#
#################################

###### --- install conan --- #####
#
ENV CONAN_USER_HOME=/home/ubuntu
COPY conan_config/ /home/ubuntu/conan_config/

RUN set -xe; \
   conan; \
   conan config set general.cmake_generator=Ninja; \
   cd /home/ubuntu/.conan;                               \
   mkdir profiles;                                       \   
   cp -r /home/ubuntu/conan_config/armv8-profiles/* profiles;        \
   mkdir tools;                                          \   
   cp -r /home/ubuntu/conan_config/armv8-tools/* tools;              \
   cp -r /home/ubuntu/conan_config/common/* tools;                     \
   cp /home/ubuntu/conan_config/settings.yml .;  

RUN sudo rm -rf conan_config
#
#################################

###### --- install Yocto support --- #####
#
# Required for Yocto install of Python programs like Conan
#
USER ubuntu
WORKDIR /home/ubuntu
RUN echo "export PATH=/home/ubuntu/.conan/tools:/home/ubuntu/.local/bin:$PATH" >> /home/ubuntu/.bashrc
RUN if [ "$IsYoctoInstall" = "yes" ]; then \
        echo "source /opt/yocto/environment-setup-aarch64-fslc-linux" >> /home/ubuntu/.bashrc; \
    fi
ENV PATH="/home/ubuntu/.local/bin:$PATH"
#
#################################

###### --- Required by Azul3DConan.py --- ###
#
RUN pip3 install pytz
RUN pip3 install tzlocal
RUN pip3 install pipoe
#
#################################

####### --- Set Environment Variables --- ###
#
ENV BRANCH_MessageCGTool=$MessageCGToolBranch
ENV BRANCH_Nvim=$NvimBranch
ENV BROKER_IP=127.0.0.1
ENV BROKER_PORT=1883
ENV DOCKER=$Name
ENV IS_LIBCXX_INSTALL=$IsLibcxxInstall
ENV IS_YOCTO_INSTALL=$IsYoctoInstall
#
#################################

######## -- install nvim -- ####
#
USER ubuntu
WORKDIR /home/ubuntu

RUN pip3 install --user pynvim
RUN --mount=type=ssh,uid=$UID git clone --branch "$NvimBranch" --single-branch git@github.com:CDJ-Technologies/nvim-dev-tools.git

ENV VIMRUNTIME=/usr/local/share/nvim/runtime

RUN mkdir -p .config/nvim && \
    cp -r nvim-dev-tools/nvim .config/ && \
    mkdir -p .local/share/nvim/site/pack/packer/start/ && \
    nvim --headless +PluginInstall +qa
#
############

######## -- config bash shell -- ####
#
USER ubuntu
SHELL ["/bin/bash", "-c"]
#
############

###### --- install MessgeCGTool --- #####
#
USER ubuntu
WORKDIR /home/ubuntu
RUN --mount=type=ssh,uid=$UID git clone --branch "$MessageCGToolBranch" --single-branch git@github.com:CDJ-Technologies/MessageCGTool.git && \
    sudo cp MessageCGTool/out/artifacts/MessageCGTool_jar/MessageCGTool.jar /usr/bin && \
    sudo chmod +x /usr/bin/MessageCGTool.jar && \
    rm -rf MessageCGTool
#
#################################

###### --- ENV Timestamp --- #####
#
RUN Timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
ENV Timestamp=$Timestamp
#
#################################

USER ubuntu
WORKDIR /repo
RUN echo "finished"

