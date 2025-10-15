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
    libc++1 \
    libc++-dev \
    libc++abi-dev \
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
# Install for epiphany to run secured
#
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    epiphany-browser gsettings-desktop-schemas adwaita-icon-theme \
    libcanberra-gtk-module dbus-x11 \
    libgl1-mesa-dri libgl1 libegl1 libgbm1 \
    libxcomposite1 libxdamage1 libxrandr2 libasound2 fonts-dejavu \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# sensible defaults for XQuartz
ENV GDK_BACKEND=x11 \
    LIBGL_ALWAYS_SOFTWARE=1 \
    WEBKIT_DISABLE_SANDBOX=1

# --- Extra tools to verify X and debug connectivity ---
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    x11-apps netcat-openbsd \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# --- Runtime dirs & additional safe defaults ---
# A stable per-container runtime dir (GTK/WebKit expect one)
ENV XDG_RUNTIME_DIR=/tmp/runtime-docker
RUN mkdir -p /tmp/runtime-docker && chmod 1777 /tmp/runtime-docker

# Disable dmabuf renderer (avoids XQuartz/GL path issues)
ENV WEBKIT_DISABLE_DMABUF_RENDERER=1

# (Optional) If you run as a non-root user later and want sudo available:
# RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y sudo \
#   && apt-get clean && rm -rf /var/lib/apt/lists/*

# --- Helper scripts to open/close Epiphany on demand ---
COPY docker/open-coverage /usr/local/bin/open-coverage
COPY docker/close-browser /usr/local/bin/close-browser
RUN chmod +x /usr/local/bin/open-coverage /usr/local/bin/close-browser

RUN apt-get --yes update && DEBIAN_FRONTEND="noninteractive" apt-get --yes install openssh-client epiphany-browser tree tmux clinfo
#
#################################

###### --- support clblast--- #####
#
RUN apt-get update && apt-get install -y --no-install-recommends unzip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt
COPY dev-tools/CLBlast-1.6.1-linux-x86_64.zip .

# Unpack and install prebuilt files
RUN set -eux; \
    unzip -q CLBlast-1.6.1-linux-x86_64.zip; \
    tar -xf CLBlast-1.6.1-linux-x86_64.tar.gz; \
    rm -f CLBlast-1.6.1-linux-x86_64.zip CLBlast-1.6.1-linux-x86_64.tar.gz; \
    # headers
    [ -d CLBlast-1.6.1-linux-x86_64/include ] && \
      cp -r CLBlast-1.6.1-linux-x86_64/include/* /usr/include/ || true; \
    # libraries
    mkdir -p /usr/lib/x86_64-linux-gnu; \
    [ -d CLBlast-1.6.1-linux-x86_64/lib ] && \
      cp -r CLBlast-1.6.1-linux-x86_64/lib/* /usr/lib/x86_64-linux-gnu/ || true; \
    # binaries (if any)
    [ -d CLBlast-1.6.1-linux-x86_64/bin ] && \
      cp -r CLBlast-1.6.1-linux-x86_64/bin/* /usr/bin/ || true; \
    # cmake/pkgconfig metadata (if present)
    if [ -d CLBlast-1.6.1-linux-x86_64/lib/cmake ]; then \
      mkdir -p /usr/lib/cmake; \
      cp -r CLBlast-1.6.1-linux-x86_64/lib/cmake/* /usr/lib/cmake/; \
    fi; \
    if [ -d CLBlast-1.6.1-linux-x86_64/lib/pkgconfig ]; then \
      mkdir -p /usr/lib/x86_64-linux-gnu/pkgconfig; \
      cp -r CLBlast-1.6.1-linux-x86_64/lib/pkgconfig/* /usr/lib/x86_64-linux-gnu/pkgconfig/; \
    fi; \
    ldconfig; \
    rm -rf CLBlast-1.6.1-linux-x86_64
#
#################################

###### --- install nvim --- #####
#
#  precompiled version copied to bin, lib and share directories
#
WORKDIR /opt
RUN apt-get update && apt-get install -y gettext unzip xclip  && rm -rf /var/lib/apt/lists/*
COPY dev-tools/nvim-linux-x86_64.tar.gz .

RUN  tar -xf nvim-linux-x86_64.tar.gz && \
     cp -r   nvim-linux-x86_64/bin/*   /usr/local/bin && \
     cp -r   nvim-linux-x86_64/lib/*   /usr/local/lib && \
     cp -r   nvim-linux-x86_64/share/* /usr/local/share

# COPY dev-tools/nvim-linux64.tar.gz .
# RUN  tar -xf nvim-linux64.tar.gz && \
#      cp -r nvim-linux64/bin/*   /usr/local/bin && \
#      cp -r nvim-linux64/lib/*   /usr/local/lib && \
#      cp -r nvim-linux64/share/* /usr/local/share
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
ARG USERNAME=ubuntu
RUN apt-get -y update && apt-get -y install xterm sudo && \
  DEBIAN_FRONTEND=noninteractive apt-get clean && rm -rf /var/lib/apt/lists/*

RUN echo "    IdentityFile ~/.ssh/id_rsa" >> /etc/ssh/ssh_config

RUN groupadd -g ${GID} ${USERNAME} \
    && useradd -rm -d /home/${USERNAME} -s /bin/bash \
         -u ${UID} -g ${GID} -G sudo ${USERNAME}

RUN echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
WORKDIR /home/${USERNAME}
ENV PATH="/home/${USERNAME}/.conan/tools:$PATH"
#
#################################

###### --- install .bash_profile --- #####
#
USER ${USERNAME}
COPY --chown=${USERNAME}:${USERNAME} .bashrc .bashrc
RUN echo "if [ -o interactive ] && [ -f ~/.bashrc ]; then\n \tsource ~/.bashrc\n fi" >> .bash_profile
#
#################################

####### --- setup security -- #################
# 
USER ${USERNAME}
WORKDIR /home/${USERNAME}

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
    ls -al; \
    cp valgrind/.valgrindrc .; \
    cp valgrind/opengl.supp .; \
    rm valgrind.tar.xz;
#
#################################

###### --- install vim --- #####
#
# Version 0.10.2
# https://github.com/VundleVim
#
ARG USERNAME=ubuntu
ENV HOME=/home/${USERNAME}

# switch to that user for all Vim steps (avoid su/sudo in builds)
USER ${USERNAME}
WORKDIR /home/${USERNAME}

# put config in the user's home (NOTE: no backtick!)
COPY --chown=${USERNAME}:${USERNAME} .vimrc ${HOME}/.vimrc
# RUN install -d -o ${USERNAME} -g ${GID} ${HOME}/.vim/bundle

# get Vundle (or COPY your vendored Vundle to the same path)
RUN git clone https://github.com/VundleVim/Vundle.vim ${HOME}/.vim/bundle/Vundle.vim
# If you vendor it:
# COPY --chown=${USERNAME}:${USERNAME} dev-tools/Vundle.vim/ ${HOME}/.vim/bundle/Vundle.vim/

# install plugins non-interactively
RUN vim -E -s -u ${HOME}/.vimrc +PluginInstall +qall

# build YouCompleteMe (clangd completer)
RUN python3 ${HOME}/.vim/bundle/YouCompleteMe/install.py --clangd-completer

# optional verify
RUN test -d ${HOME}/.vim/bundle/YouCompleteMe && echo "YCM present"
#
#################################

###### --- install conan --- #####
#
COPY --chown=${USERNAME}:${USERNAME} conan_config/ ${HOME}/conan_config/

# Make Conan act on ubuntu's home
ENV CONAN_USER_HOME=${HOME} \
    CONAN_HOME=${HOME}/.conan

# Do all Conan work as ubuntu (no su/sudo needed)
USER ${USERNAME}
WORKDIR ${HOME}

RUN set -eux; \
    # Initialize Conan config in ubuntu's home
    conan config set general.cmake_generator=Ninja; \
    mkdir -p "${CONAN_HOME}/profiles" "${CONAN_HOME}/tools"; \
    # Copy profiles/tools/common without using globs
    cp -r "${HOME}/conan_config/x86_64-profiles/." "${CONAN_HOME}/profiles/"; \
    cp -r "${HOME}/conan_config/x86_64-tools/."    "${CONAN_HOME}/tools/"; \
    cp -r "${HOME}/conan_config/common/."          "${CONAN_HOME}/tools/"; \
    cp     "${HOME}/conan_config/settings.yml"     "${CONAN_HOME}/"; \
    # sanity checks
    ls -la "${CONAN_HOME}" "${CONAN_HOME}/profiles" "${CONAN_HOME}/tools"

RUN sudo rm -rf conan_config
#
#################################

###### --- install Maven --- #####
#
# Install maven v3.8.8, as v3.6.3, which is in the apt repository for 20.04, crashes
# fatally on run with OpenJDK 16, which we use. 
#
# Assume you already created the user earlier:
ARG USERNAME=ubuntu
ENV HOME=/home/${USERNAME}

############################
# System-level installs
############################
USER root

# # Example: JDK (for Maven), git, build tools, etc.
# RUN apt-get update && apt-get install -y --no-install-recommends \
#       openjdk-17-jdk-headless git cmake clangd ca-certificates \
#     && rm -rf /var/lib/apt/lists/*

# Maven from local tarball (binary install)
ARG MAVEN_VERSION=3.8.8
ARG MAVEN_TGZ=apache-maven-${MAVEN_VERSION}-bin.tar.gz
COPY dev-tools/${MAVEN_TGZ} /tmp/
RUN set -eux; \
    mkdir -p /opt; \
    tar -xzf /tmp/${MAVEN_TGZ} -C /opt; \
    ln -sfn /opt/apache-maven-${MAVEN_VERSION} /opt/maven; \
    ln -sfn /opt/maven/bin/mvn /usr/local/bin/mvn; \
    rm -f /tmp/${MAVEN_TGZ}
ENV MAVEN_HOME=/opt/maven M2_HOME=/opt/maven PATH="/opt/maven/bin:${PATH}"

############################
# Per-user configs (run as user)
############################
# Put user dotfiles in place
# Assume you already created the user earlier:
ARG USERNAME=ubuntu
ENV HOME=/home/${USERNAME}

# COPY --chown=${USERNAME}:${USERNAME} .vimrc ${HOME}/.vimrc
# RUN install -d -o ${USERNAME} -g ${USERNAME} ${HOME}/.vim/bundle
# 
# # Clone Vundle as the user
# RUN su -l ${USERNAME} -c 'git clone https://github.com/VundleVim/Vundle.vim ~/.vim/bundle/Vundle.vim'
# 
# # Install plugins (must run as the user who owns ~/.vimrc)
# RUN su -l ${USERNAME} -c 'vim -E -s -u ~/.vimrc +PluginInstall +qall'
# 
# # Build YCM (example)
# RUN su -l ${USERNAME} -c 'python3 ~/.vim/bundle/YouCompleteMe/install.py --clangd-completer'
# 
# Conan config (copy then configure as user)
COPY --chown=${USERNAME}:${USERNAME} conan_config/ ${HOME}/conan_config/
RUN su -l ${USERNAME} -c '\
  conan config set general.cmake_generator=Ninja && \
  mkdir -p ~/.conan/profiles ~/.conan/tools && \
  cp -r ~/conan_config/x86_64-profiles/. ~/.conan/profiles/ && \
  cp -r ~/conan_config/x86_64-tools/.    ~/.conan/tools/ && \
  cp -r ~/conan_config/common/.          ~/.conan/tools/ && \
  cp    ~/conan_config/settings.yml      ~/.conan/ \
'

# Drop privileges for the rest of the image
USER ${USERNAME}
WORKDIR ${HOME}

# RUN set -xe; \
#     mkdir /home/ubuntu/tools; \
#     wget -P /home/ubuntu/tools/ https://dlcdn.apache.org/maven/maven-3/3.8.8/binaries/apache-maven-3.8.8-bin.tar.gz; \
#     tar -C /home/ubuntu/tools -xzf /home/ubuntu/tools/apache-maven-3.8.8-bin.tar.gz; \
#     sudo cp -r /home/ubuntu/tools/apache-maven-3.8.8/bin/mvn /usr/bin/mvn; \
#     # sudo ln -sf /home/ubuntu/tools/apache-maven-3.8.8/bin/mvn /usr/bin/mvn; \
#     rm /home/ubuntu/tools/apache-maven-3.8.8-bin.tar.gz;    
#
#################################

###### --- Required by ConanExtension.py --- ###
#
RUN pip3 install pytz
RUN pip3 install tzlocal
RUN pip3 install pipoe
#
#################################

####### --- Set Environment Variables --- ###
#
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

# --TODO-- ######## -- install nvim -- ####
# --TODO-- #
# --TODO-- USER ubuntu
# --TODO-- WORKDIR /home/ubuntu
# --TODO-- 
# --TODO-- RUN pip3 install --user pynvim
# --TODO-- RUN --mount=type=ssh,uid=$UID git clone --branch "$NvimBranch" --single-branch git@github.com:CDJ-Technologies/nvim-dev-tools.git
# --TODO-- 
# --TODO-- ENV VIMRUNTIME=/usr/local/share/nvim/runtime
# --TODO-- 
# --TODO-- RUN mkdir -p .config/nvim && \
# --TODO--     cp -r nvim-dev-tools/nvim .config/ && \
# --TODO--     mkdir -p .local/share/nvim/site/pack/packer/start/ && \
# --TODO--     nvim --headless +PluginInstall +qa
# --TODO-- #
# --TODO-- ############

########### --- Web desktop (noVNC) + browser ---
USER root

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    xfce4 xfce4-terminal dbus-x11 xfonts-base \
    xvfb x11vnc novnc websockify \
    # epiphany-browser \
    supervisor && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# noVNC lives here on Ubuntu
ENV NOVNC_DIR=/usr/share/novnc
ENV WEBSOCKIFY_DIR=/usr/share/novnc/utils/websockify

# Set display and a default resolution (change as you like)
ENV DISPLAY=:0
ENV GEOMETRY=1280x800

# VNC password (change this!); x11vnc reads this file
RUN mkdir -p /etc/x11vnc && \
    x11vnc -storepasswd secret /etc/x11vnc/vncpwd

# Supervisor config
COPY docker/noVNC-supervisord.conf /etc/supervisor/conf.d/novnc.conf
#
############

######## -- config bash shell -- ####
#
USER ubuntu
SHELL ["/bin/bash", "-c"]
#
############

###### --- ENV Timestamp --- #####
#
RUN Timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
ENV Timestamp=$Timestamp
#
#################################

USER ubuntu
WORKDIR /repo
RUN echo "finished"

