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

###### --- install tools for building dpc++ --- #####
#
# python3 \
#
RUN apt update && apt install -yqq \
      ccache \
      python3-distutils \
      python-is-python3 \
      zstd \
      ocl-icd-opencl-dev \
      libffi-dev \
      libva-dev
#
#################################

###### --- install gcov and libc++ --- #####
#
# Install system dependencies with correct package names
RUN apt-get --yes update && \
    DEBIAN_FRONTEND="noninteractive" apt-get --yes install \
    lcov \
    libc++1-10 \
    libc++-10-dev \
    libc++abi-dev \
    libc++abi-10-dev \
    lsb-release \
    software-properties-common \
    gpg

#
#################################

###### --- install llvm 15 for GCOV --- #####
#
#  using the llvm tools for code coverage
#
COPY llvm-gcov.sh /usr/bin
RUN wget https://apt.llvm.org/llvm.sh
RUN chmod +x llvm.sh
RUN ./llvm.sh 15
#
#################################

###### --- install boost --- #####
#
# Installs boost 1.7.1
#
# How to get boost source: 
#    wget https://boostorg.jfrog.io/artifactory/main/release/1.71.0/source/boost_1_71_0.tar.gz; \
#
COPY dev-tools/boost_1_71_0.tar.gz .
COPY boost/patch/workaround.hpp .

RUN if [ "$IsLibcxxInstall" = "yes" ]; then \
        echo "MISTAKE"; \
    else \
        echo "GOOD!"; \
    fi
RUN if [ "$IsLibcxxInstall" = "yes" ]; then \
        echo "IsLibcxxInstall=$IsLibcxxInstall" > /opt/IsLibcxxInstall.txt; \
        mkdir -p /usr/src/boost /usr/include/boost/config; \
        tar -xzf boost_1_71_0.tar.gz; \
        cd boost_1_71_0;              \
        ./bootstrap.sh --with-toolset=clang --prefix=/usr; \
        ./b2 clean; \
        ./b2 toolset=clang cxxflags="-std=c++17 -stdlib=libc++" linkflags="-stdlib=libc++" \
           --prefix=/usr -j$(nproc) stage release; \
        ./b2 install toolset=clang cxxflags="-std=c++17 -stdlib=libc++" linkflags="-stdlib=libc++" \
           --prefix=/usr; \
        cd ..; \
        rm -rf /usr/src/boost; \
        rm -rf boost_1_71_0*; \
        cp workaround.hpp /usr/include/boost/config/workaround.hpp; \
    else \
        echo "IsLibcxxInstall=$IsLibcxxInstall" > /opt/IsLibcxxInstall.txt; \
        apt update && apt-get install -y boost1.71; \
        rm /lib/x86_64-linux-gnu/libboost_filesystem.so.1.71.0 \
           /lib/x86_64-linux-gnu/libboost_filesystem.so \
           /lib/x86_64-linux-gnu/libboost_system.so.1.71.0 \
           /lib/x86_64-linux-gnu/libboost_system.so \
           /lib/x86_64-linux-gnu/libboost_program_options.so.1.71.0 \
           /lib/x86_64-linux-gnu/libboost_program_options.so \
           /lib/x86_64-linux-gnu/libboost_random.so.1.71.0 \
           /lib/x86_64-linux-gnu/libboost_random.so \
           /lib/x86_64-linux-gnu/libboost_date_time.so.1.71.0 \
           /lib/x86_64-linux-gnu/libboost_date_time.so; \
    fi
#
#################################

###### --- install mosquitto support --- #####
#
WORKDIR /etc/mosquitto
COPY etc/mosquitto/mosquitto_x86_64.conf /etc/mosquitto/mosquitto.conf
RUN cp /sbin/mosquitto /usr/bin/
#
#################################

###### --- install openssh-client, epiphany browser, tree, tmux and opencl --- #####
#
RUN apt-get --yes update && DEBIAN_FRONTEND="noninteractive" apt-get --yes install openssh-client epiphany-browser tree tmux clinfo
#
#################################

###### --- support clblast--- #####
#
WORKDIR /opt
COPY      dev-tools/CLBlast-1.6.1.tar.gz .
RUN set -xe; \
   tar xf CLBlast-1.6.1.tar.gz; \
   cd     CLBlast-1.6.1; \
   mkdir build; \
   cd build; \
   cmake -DCMAKE_INSTALL_PREFIX=/usr -DBUILD_SHARED_LIBS=OFF ..; \
   make; \
   make install; \
   cd ../..; rm -rf CLBlast*;
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

###### --- install gtest --- #####
#
# Installs 1.11.0 
#
RUN git clone -b release-1.11.0 https://github.com/google/googletest.git; \
    cd googletest; \
    mkdir build; \
    cd build && cmake -G"Unix Makefiles" ..; \
    make && make install;
#
#################################

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
WORKDIR /home/ubuntu
COPY .bashrc .bashrc
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
   cp -r /home/ubuntu/conan_config/x86_64-profiles/* profiles;        \
   mkdir tools;                                          \
   cp -r /home/ubuntu/conan_config/x86_64-tools/* tools;              \
   cp -r /home/ubuntu/conan_config/common/* tools;                     \
   cp /home/ubuntu/conan_config/settings.yml .;  

RUN sudo rm -rf conan_config
#
#################################

###### --- install Maven --- #####
#
# Install maven v3.8.8, as v3.6.3, which is in the apt repository for 20.04, crashes
# fatally on run with OpenJDK 16, which we use. 
#
RUN set -xe; \
    mkdir /home/ubuntu/tools; \
    wget -P /home/ubuntu/tools/ https://dlcdn.apache.org/maven/maven-3/3.8.8/binaries/apache-maven-3.8.8-bin.tar.gz; \
    tar -C /home/ubuntu/tools -xzf /home/ubuntu/tools/apache-maven-3.8.8-bin.tar.gz; \
    sudo cp -r /home/ubuntu/tools/apache-maven-3.8.8/bin/mvn /usr/bin/mvn; \
    # sudo ln -sf /home/ubuntu/tools/apache-maven-3.8.8/bin/mvn /usr/bin/mvn; \
    rm /home/ubuntu/tools/apache-maven-3.8.8-bin.tar.gz;    
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

# extraneous inclusion of unwanted version
RUN sudo rm -rf /usr/lib/gcc/x86_64-linux-gnu/13

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

