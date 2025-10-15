FROM base-img

ARG SSH_KEY
ARG UID
ARG GID

RUN cmake --version

# Upgrade system and Yocto Project basic dependencies
RUN apt-get -y update && apt-get -y upgrade && DEBIAN_FRONTEND="noninteractive" apt-get -y install \
    python-git-doc \
    gawk \
    git-core \
    diffstat \
    unzip \
    texinfo \
    chrpath \
    socat \
    cpio \
    python \
    python3-pexpect \
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
    subversion \
    coreutils \
    texi2html \
    docbook-utils \
    python-pysqlite2 \
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
   
###### --- install mosquitto support --- #####
#
RUN ls -al /etc
WORKDIR /etc/mosquitto
COPY etc/mosquitto/mosquitto_armv8.conf mosquitto.conf
#
#################################

#-# ##### --- install cmake --- #####
#-# WORKDIR /usr/src
#-# 
#-# RUN set -xe; \
#-#     wget https://cmake.org/files/v3.20/cmake-3.20.2-linux-x86_64.tar.gz; \
#-#     tar xvf cmake-3.20.2-linux-x86_64.tar.gz; \
#-#     cd cmake-3.20.2-linux-x86_64; \
#-#     cd ../; \
#-#     rm -rf cmake-3.20.2-linux-x86_64.tar.gz;
#-# ################################

###### --- install locales --- #####
#-wpd-# RUN set -xe; \
#-wpd-#     apt update; \
#-wpd-#     DEBIAN_FRONTEND="noninteractive" apt-get -y install locales apt-utils sudo; \
#-wpd-#     dpkg-reconfigure locales; \
#-wpd-#     locale-gen en_US.UTF-8 ; \
#-wpd-#     update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8;
#-wpd-# ENV LANG en_US.utf8
#################################

##############################################################################################

###### --- install user --- #####
# Needed for ssh
#
RUN echo "    IdentityFile ~/.ssh/id_rsa" >> /etc/ssh/ssh_config

RUN useradd -rm -d /home/ubuntu -s /bin/bash -g root -G sudo -u $GID ubuntu

RUN echo "ubuntu ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
WORKDIR /home/ubuntu
COPY .bashrc bashrc
RUN cat bashrc >> .bashrc
RUN rm bashrc
ENV PATH "/home/ubuntu/.conan/tools:$PATH"

USER ubuntu
RUN echo "if [ -o interactive ] && [ -f ~/.bashrc ]; then\n \tsource ~/.bashrc\n fi" >> .bash_profile
#
#################################

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

RUN clang --version
RUN g++ --version
RUN aarch64-linux-gnu-g++ --version

###### --- install vim --- #####
#
COPY .vimrc .
COPY Vundle.vim/ .vim/bundle/Vundle.vim/
RUN set -xe; \
    mkdir -p /home/ubuntu/.vim-tmp; \
    sudo chown -R ubuntu .vim; \
    #git clone https://github.com/VundleVim/Vundle.vim.git .vim/bundle/Vundle.vim; \
    vim -c 'PluginInstall' -c 'qa!'; \
    cd .vim/bundle/YouCompleteMe; \
    python3 install.py --clangd-completer;
#
#################################

###### --- install for nvim --- #####
#
COPY .config .config
#
######

# Required for Yocto install of Python programs like Conan
RUN echo "export PATH=/home/ubuntu/.conan/tools:/home/ubuntu/.local/bin:$PATH" >> .bashrc
# RUN echo "source /opt/yocto/environment-setup-aarch64-fslc-linux" >> .bashrc
RUN echo "source /opt/yocto/environment-setup-aarch64-poky-linux" >> .bashrc
ENV PATH "/home/ubuntu/.local/bin:$PATH"

RUN cmake --version

###### --- install conan --- #####
#
ENV CONAN_USER_HOME=/home/ubuntu
WORKDIR /home/ubuntu
ADD conan_config/ conan_config

RUN set -xe; \
   conan; \
   conan config set general.cmake_generator=Ninja; \
   cd /home/ubuntu/.conan;                               \
   mkdir profiles;                                       \   
   cp -r /home/ubuntu/conan_config/armv8-zeus-profiles/* profiles;        \
   mkdir tools;                                          \   
   cp -r /home/ubuntu/conan_config/armv8-zeus-tools/* tools;              \
   cp -r /home/ubuntu/conan_config/common/* tools;                     \
   cp /home/ubuntu/conan_config/settings.yml .;  

RUN sudo rm -rf conan_config
  
RUN conan remote add gitlab https://gitlab.com/api/v4/projects/21201357/packages/conan
#
#################################

RUN cmake --version

################################ Install Yocto ################################################
# Copy Variscite Linux kernel to container
#
COPY linux-imx /lib/modules/5.4.142/build

WORKDIR /opt
COPY fsl-imx-xwayland-glibc-x86_64-fsl-image-gui-aarch64-imx8mq-var-dart-toolchain-5.4-zeus.sh .
#COPY fslc-xwayland-glibc-x86_64-fsl-image-gui-aarch64-imx8mq-var-dart-toolchain-3.1.sh .
RUN printf '/opt/yocto\ny\n' |  ./fsl-imx-xwayland-glibc-x86_64-fsl-image-gui-aarch64-imx8mq-var-dart-toolchain-5.4-zeus.sh
#RUN printf '/opt/yocto\ny\n' |  ./fslc-xwayland-glibc-x86_64-fsl-image-gui-aarch64-imx8mq-var-dart-toolchain-3.1.sh

WORKDIR /opt
RUN sudo rm fsl-imx-xwayland-glibc-x86_64-fsl-image-gui-aarch64-imx8mq-var-dart-toolchain-5.4-zeus.sh 
#RUN sudo rm fslc-xwayland-glibc-x86_64-fsl-image-gui-aarch64-imx8mq-var-dart-toolchain-3.1.sh 
#
#################################

COPY MessageCGTool/out/artifacts/MessageCGTool_jar/MessageCGTool.jar /usr/bin

# Required by Azul3DConan.py
RUN pip3 install pytz
RUN pip3 install tzlocal
RUN pip3 install pipoe

ENV SSH_KEY=$SSH_KEY

# Make ssh dir
RUN mkdir /home/ubuntu/.ssh/
 
# Create id_rsa from string arg, and set permissions

RUN echo "$SSH_KEY" > /home/ubuntu/.ssh/id_rsa
RUN chmod 600 /home/ubuntu/.ssh/id_rsa
 
# Create known_hosts
RUN touch /home/ubuntu/.ssh/known_hosts

RUN ssh-keyscan github.com >> /home/ubuntu/.ssh/known_hosts

ENV DOCKER=armv8-zeus-img

###### -- remove all tool conflicts with SDK ################################################
#
#RUN sudo rm /opt/yocto/sysroots/x86_64-fslcsdk-linux//usr/bin/python3
#
##############################################################################################


SHELL ["/bin/bash", "-c"]

RUN cmake --version

WORKDIR /repo
RUN echo "finished"
