# ARG Base

# Not used
# FROM ${Base} 

FROM ubuntu:22.04 

RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get install -y \
  wget \
  build-essential \
  libncurses5-dev \
  libgtk-3-dev \
  libatk1.0-dev \
  libcairo2-dev \
  libx11-dev \
  libxpm-dev \
  libxt-dev && \
  DEBIAN_FRONTEND=noninteractive apt-get clean && rm -rf /var/lib/apt/lists/*

#-PYTHON3.8-# # WORKDIR /usr/local/lib
#-PYTHON3.8-# 
#-PYTHON3.8-# RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get upgrade -y && apt-get install -y software-properties-common && add-apt-repository ppa:deadsnakes/ppa -y && \
#-PYTHON3.8-#     DEBIAN_FRONTEND=noninteractive apt-get install -y python3.8 python3.8-distutils python3-pip python3.8-dev && \
#-PYTHON3.8-#     DEBIAN_FRONTEND=noninteractive apt-get clean && rm -rf /var/lib/apt/lists/*
#-PYTHON3.8-# 
#-PYTHON3.8-# # Let's remove all the links to python3.10
#-PYTHON3.8-# WORKDIR /usr/bin
#-PYTHON3.8-# RUN rm pdb3 && rm pydoc3 && rm pygettext3 && rm python3
#-PYTHON3.8-# 
#-PYTHON3.8-# # Let's rename the python links from 3.10 to 3.8
#-PYTHON3.8-# RUN ln -s pdb3.8 pdb3
#-PYTHON3.8-# RUN ln -s pydoc3.8 pydoc3
#-PYTHON3.8-# RUN ln -s pygettext3.8 pygettext3
#-PYTHON3.8-# RUN ln -s python3.8 python3

############################################
#
# Build and install vim
# 
# RUN wget --no-check-certificate  https://github.com/vim/vim/archive/v$VER.tar.gz; \

ARG VER="9.1.0016"
COPY dev-tools/vim-$VER.tar.gz .
RUN tar xf vim-$VER.tar.gz; \
    cd vim-$VER/src; \
    ./configure \
      --enable-cscope \
      --disable-darwin   \
      --disable-smack    \
      --enable-pythoninterp=yes   \
      --enable-python3interp=yes  \
      --enable-rubyinterp=no   \
      --enable-cscope \
      --disable-netbeans \
      --enable-terminal  \
      --enable-autoservername  \
      --disable-rightleft        \
      --disable-rightleft   \
      --disable-arabic   \
      --disable-farsi \
      --enable-xim \
      --enable-fontset   \
      --enable-gui=athena  \
      --enable-gtk2-check   \
      --enable-gnome-check  \
      --enable-gtk3-check   \
      --enable-motif-check  \
      --enable-athena-check \
      --enable-nextaw-check \
      --disable-icon-cache-update \
      --disable-desktop-database-update \
      --with-features=huge \
      --enable-python3interp=yes \
      --with-python3-config-dir=/usr/local/lib/python3.8 && \
    make -j$(nproc) && \
    make install
#
############################################

#-PYTHON3.8-# ############################################
#-PYTHON3.8-# #
#-PYTHON3.8-# #
#-PYTHON3.8-# # Let's remove all the links to python3.10
#-PYTHON3.8-# WORKDIR /usr/bin
#-PYTHON3.8-# RUN rm pdb3 && rm pydoc3 && rm pygettext3 && rm python3
#-PYTHON3.8-# 
#-PYTHON3.8-# # Let's rename the links to python3.10
#-PYTHON3.8-# RUN ln -s pdb3.10 pdb3
#-PYTHON3.8-# RUN ln -s pydoc3.10 pydoc3
#-PYTHON3.8-# RUN ln -s pygettext3.10 pygettext3
#-PYTHON3.8-# RUN ln -s python3.10 python3
#-PYTHON3.8-# #
#-PYTHON3.8-# ############################################

RUN apt-get --yes update && DEBIAN_FRONTEND="noninteractive" apt-get --yes install \
    git \
    flex \
    bison \
    curl \
    python3-dev \
    python3-setuptools \
    python3-pip \
    python3-wheel \
    python-six \
    libicu-dev \
    libbz2-dev \
    libssl-dev \
    libz-dev \
    libblas-dev \
    liblapack-dev && \
    DEBIAN_FRONTEND=noninteractive apt-get clean && rm -rf /var/lib/apt/lists/*

RUN apt-get --yes update && DEBIAN_FRONTEND="noninteractive" apt-get --yes install \
    autotools-dev \
    automake \
    libtool \
    clang-14 \
    ninja-build \
    valgrind \
    expect-dev \
    elfutils \
    mosquitto \
    patchelf \
    libusb-1.0 && \
    DEBIAN_FRONTEND=noninteractive apt-get clean && rm -rf /var/lib/apt/lists/*
#
############################################

##### --- install java --- #####
#
WORKDIR /opt/java
COPY    dev-tools/openjdk-25_linux-x64_bin.tar.gz .
# COPY    dev-tools/openjdk-16.0.1_linux-x64_bin.tar.gz .
RUN    tar xfvz openjdk-25_linux-x64_bin.tar.gz
# RUN     tar xfvz openjdk-16.0.1_linux-x64_bin.tar.gz 

WORKDIR /opt
COPY    install-java.sh .
RUN     ./install-java.sh

RUN rm -rf openjdk-25_linux-x64_bin.tar.gz
# RUN rm -rf openjdk-16.0.1_linux-x64_bin
# RUN java -version
#
################################

##### --- install cmake --- #####
#
WORKDIR /usr/src

RUN set -xe; \
    wget https://cmake.org/files/v3.18/cmake-3.18.0-Linux-x86_64.tar.gz; \
    tar xvf cmake-3.18.0-Linux-x86_64.tar.gz; \
    cd cmake-3.18.0-Linux-x86_64; \
    ln -s $(pwd)/bin/cmake /usr/local/bin; \
    ln -s $(pwd)/bin/ctest /usr/local/bin; \
    cd ../; \
    rm -rf cmake-3.18.0-Linux-x86_64.tar.gz;
#
################################

#-evaluate-# ###### --- TODO: move to ARM --- #####
#-evaluate-# ###### --- install real-time --- #####
#-evaluate-# #
#-evaluate-# RUN echo 'kernel.sched_rt_runtime_us=-1' > /etc/sysctl.conf
#-evaluate-# RUN sysctl -w kernel.sched_rt_runtime_us=-1
#-evaluate-# #
#-evaluate-# ################################
#-evaluate-# 
#-evaluate-# ###### --- TODO: move to ARM --- #####
#-evaluate-# ###### --- install arm cross compiler --- #####
#-evaluate-# #
#-evaluate-# RUN apt-get -y install p7zip-full
#-evaluate-# RUN apt-get --yes update && apt-get -y install g++-aarch64-linux-gnu
#-evaluate-# RUN apt-get --yes update && apt-get -y install gcc-aarch64-linux-gnu
#-evaluate-# #
#-evaluate-# ################################

#-legacy-microsoft-# #--- DO NOT DELETE ---#
#-legacy-microsoft-# ### Redo the symbolic links. Note: investigate whether there is an install option to set the symbolic links correctly
#-legacy-microsoft-# # RUN apt-get -y install mingw-w64
#-legacy-microsoft-# # COPY mingw-fix.tar.gz .
#-legacy-microsoft-# # RUN tar xvf mingw-fix.tar.gz
#-legacy-microsoft-# # RUN ./mingw-fix.sh

### ---- OpenGL ---- ###

###### --- install meson --- #####
#
RUN apt-get -y update &&  apt-get -y install ninja-build && \
    DEBIAN_FRONTEND=noninteractive apt-get clean && rm -rf /var/lib/apt/lists/*
#
################################

#-evaluate-# ##### --- TODO: move to ARM --- #####
#-evaluate-# UN pip3 install meson
#-evaluate-# 
#-evaluate-# ###############################

#################################


###### --- install opengl stuff --- #####
#
RUN apt-get -y update && apt-get -y install xvfb \
    libx11-xcb-dev \
    libxcb-dri2-0-dev \
    libxcb-xfixes0-dev \
    libdrm-dev \
    x11-utils \
    xserver-xorg-dev \
    expat \
    xorg-dev \
    libglew-dev \
    libglfw3-dev \
    mesa-utils \
    libgles2-mesa-dev && \
    DEBIAN_FRONTEND=noninteractive apt-get clean && rm -rf /var/lib/apt/lists/*
#
#################################

###### --- install node.js --- #####
#
COPY dev-tools/node-v20.9.0-linux-x64.tar.xz .
RUN set -xe; \
   tar xf node-v20.9.0-linux-x64.tar.xz; \
   cd node-v20.9.0-linux-x64; \
   cp -a bin /usr; \
   cp -a include /usr; \
   cp -a lib /usr; \
   cp -a share /usr;
#
#################################

############################################
#
# Build and install vim
# 
# RUN wget --no-check-certificate  https://github.com/vim/vim/archive/v$VER.tar.gz; \

ARG VER="9.1.0016"
COPY dev-tools/vim-$VER.tar.gz .
RUN tar xf vim-$VER.tar.gz; \
    cd vim-$VER/src; \
    ./configure \
      --enable-cscope \
      --disable-darwin   \
      --disable-smack    \
      --enable-pythoninterp=yes   \
      --enable-python3interp=yes  \
      --enable-rubyinterp=no   \
      --enable-cscope \
      --disable-netbeans \
      --enable-terminal  \
      --enable-autoservername  \
      --disable-rightleft        \
      --disable-rightleft   \
      --disable-arabic   \
      --disable-farsi \
      --enable-xim \
      --enable-fontset   \
      --enable-gui=athena  \
      --enable-gtk2-check   \
      --enable-gnome-check  \
      --enable-gtk3-check   \
      --enable-motif-check  \
      --enable-athena-check \
      --enable-nextaw-check \
      --disable-icon-cache-update \
      --disable-desktop-database-update \
      --with-features=huge && \
    make -j$(nproc) && \
    make install
#
############################################


RUN apt-get -y update && apt-get -y install sshpass && DEBIAN_FRONTEND=noninteractive apt-get clean && rm -rf /var/lib/apt/lists/*

RUN apt-get -y update && apt-get -y install rsync tzdata && DEBIAN_FRONTEND=noninteractive apt-get clean && rm -rf /var/lib/apt/lists/*
ENV TZ=America/Chicago

RUN apt-get -y update && apt-get -y install libfmt-dev && DEBIAN_FRONTEND=noninteractive apt-get clean && rm -rf /var/lib/apt/lists/*

# Ensure target dirs exist and are traversable
RUN install -d -m 0755 /usr/local/lib/python3.10/dist-packages /usr/local/bin

# Copy with explicit permissions (requires BuildKit-era Docker)
COPY --chmod=0644 ConanExtension.py /usr/local/lib/python3.10/dist-packages/
COPY --chmod=0644 Colorcodes.py  /usr/local/lib/python3.10/dist-packages/

ENV PYTHONPATH=/usr/local/lib/python3.10/dist-packages/

###### --- install for PlantUML Diagrams Only (for x86_64 platforms only) --- #####
#
COPY --chmod=0644 dev-tools/plantuml.jar /usr/local/bin/
COPY --chmod=0755 buildUML.sh /usr/local/bin/
#
######

##### --- install conan --- #####
#
WORKDIR /opt
RUN apt-get -qq update && apt-get -qq -y install gdb && pip3 install --upgrade pip

RUN set -xe; \
   git clone --single-branch -b release/1.43 https://github.com/conan-io/conan.git; \
   pip3 install markupsafe==2.0.1; \
   cd conan; \
   vim conans/client/build/cmake.py -c "let @l=\"329GIreturn \<Esc>\" | argdo normal @l | ZZ"; \
   vim conans/client/build/cmake.py -c "let @l=\"291GA 0\<Esc>2jIreturn \<Esc>\" | argdo normal @l | ZZ"; \
   vim conans/client/build/cmake.py -c "let @l=\"233Goretcode = 0\<Esc>14jIretcode = \<Esc>\$i, ignore_errors=True\<Esc>jI\<Enter>        return retcode\<Enter>\<Esc>\" | argdo normal @l | ZZ"; \
   pip3 install -e .;

RUN conan --version

#
################################

###### --- install for CMake Modules --- #####
#
WORKDIR /opt/modules
COPY --chmod=0644 modules .
#
######

###### --- Supports Running GTest on ARM Boards --- #####
#
ENV BOARD="10.1.10.1"
#
######

RUN echo ">*** BASE FINISHED ***<"
