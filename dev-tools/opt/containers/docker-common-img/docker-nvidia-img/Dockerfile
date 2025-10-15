# syntax=docker/dockerfile:1.4

FROM jammy-base-img

ARG UID
ARG GID
ARG Name
ARG MessageCGToolBranch
ARG NvimBranch

#################################


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
RUN apt-get --yes update && DEBIAN_FRONTEND="noninteractive" apt-get --yes install \
    lcov \
    libc++1 \
    libc++-dev \
    libc++abi-dev

COPY llvm-gcov.sh /usr/bin
#
#################################

###### --- install llvm 15 for GCOV --- #####
#
#  using the llvm tools for code coverage
#
RUN wget https://apt.llvm.org/llvm.sh
RUN chmod +x llvm.sh
RUN ./llvm.sh 15
#
#################################

###### --- install mosquitto support --- #####
#
RUN ls -al /etc
WORKDIR /etc/mosquitto
COPY etc/mosquitto/mosquitto_x86_64.conf /etc/mosquitto/mosquitto.conf
RUN cp /sbin/mosquitto /usr/bin/
#
#################################

###### --- install boost --- #####
#
# Installs boost 1.74.0
#
RUN apt-get update && apt-get install -y libboost-all-dev
#
#################################

###### --- AutoShader support --- #####
#
#-CRASHES-UBUNTU 22.04 ON LINKING-# RUN apt-get --yes update && DEBIAN_FRONTEND="noninteractive" apt-get --yes install libjemalloc-dev libblosc-dev && \
#-CRASHES-UBUNTU 22.04 ON LINKING-#     DEBIAN_FRONTEND=noninteractive apt-get clean && rm -rf /var/lib/apt/lists/*
#-CRASHES-UBUNTU 22.04 ON LINKING-# 
#-CRASHES-UBUNTU 22.04 ON LINKING-# WORKDIR /opt
#-CRASHES-UBUNTU 22.04 ON LINKING-# COPY oneTBB-2021.9.0.tar.gz .
#-CRASHES-UBUNTU 22.04 ON LINKING-# RUN set -xe; \
#-CRASHES-UBUNTU 22.04 ON LINKING-#    tar xf oneTBB-2021.9.0.tar.gz; \
#-CRASHES-UBUNTU 22.04 ON LINKING-#    cd oneTBB-2021.9.0; \
#-CRASHES-UBUNTU 22.04 ON LINKING-#    cmake .; \
#-CRASHES-UBUNTU 22.04 ON LINKING-#    cmake --build .; \
#-CRASHES-UBUNTU 22.04 ON LINKING-#    cmake --install .;
#-CRASHES-UBUNTU 22.04 ON LINKING-# 
#-CRASHES-UBUNTU 22.04 ON LINKING-# WORKDIR /opt
#-CRASHES-UBUNTU 22.04 ON LINKING-# COPY openvdb-10.0.0.tar.gz .
#-CRASHES-UBUNTU 22.04 ON LINKING-# RUN set -xe; \
#-CRASHES-UBUNTU 22.04 ON LINKING-#    tar xf openvdb-10.0.0.tar.gz; \
#-CRASHES-UBUNTU 22.04 ON LINKING-#    cd openvdb-10.0.0; \
#-CRASHES-UBUNTU 22.04 ON LINKING-#    mkdir build; cd build; \
#-CRASHES-UBUNTU 22.04 ON LINKING-#    cmake .. -DUSE_NANOVDB=ON -DCMAKE_INSTALL_PREFIX=/usr; \
#-CRASHES-UBUNTU 22.04 ON LINKING-#    make -j$(nporc);
#-CRASHES-UBUNTU 22.04 ON LINKING-#    # make -j$(nporc); \
#-CRASHES-UBUNTU 22.04 ON LINKING-#    # make install;
#-CRASHES-UBUNTU 22.04 ON LINKING-# 
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
RUN  tar -xf nvim-linux64.tar.gz &&  \
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
RUN busted --version
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
#
#################################

####### --- Set Environment Variables --- ###
#
ENV BRANCH_MessageCGTool=$MessageCGToolBranch
ENV BRANCH_Nvim=$NvimBranch
ENV BROKER_IP=127.0.0.1
ENV BROKER_PORT=1883
ENV DOCKER_Name=$Name
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
    git clone --depth 1 https://github.com/wbthomason/packer.nvim .local/share/nvim/site/pack/packer/start && \
    nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
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

USER ubuntu
WORKDIR /repo
RUN echo "finished"

