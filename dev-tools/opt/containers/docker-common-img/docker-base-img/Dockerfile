ARG Base

FROM ${Base}

RUN apt-get --yes update && DEBIAN_FRONTEND="noninteractive" apt-get --yes install \
    git \
    wget \
    flex \
    bison \
    curl \
    python3-dev \
    python3-setuptools \
    python3-pip \
    python-dev \
    python3-setuptools \
    python3-wheel \
    python-six \
    libicu-dev \
    libbz2-dev \
    libssl-dev \
    libz-dev \
    libblas-dev \
    liblapack-dev

RUN apt-get --yes update && DEBIAN_FRONTEND="noninteractive" apt-get --yes install \
    build-essential \
    autotools-dev \
    automake \
    libtool \
    clang-10 \
    lldb-3.9 \
    ninja-build \
    valgrind \
    expect-dev \
    libncurses5-dev \
    libncursesw5-dev \
    elfutils \
    patchelf \
    libusb-1.0 \
    libcairo2-dev


################################
#
# RUN add-apt-repository ppa:mosquitto-dev/mosquitto-ppa && apt-get --yes update && DEBIAN_FRONTEND="noninteractive" apt-get --yes install mosquitto
#
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:mosquitto-dev/mosquitto-ppa && \
    apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get install -y mosquitto
#    DEBIAN_FRONTEND="noninteractive" apt-get install -y mosquitto && \
#    apt-get clean && \
#    rm -rf /var/lib/apt/lists/*

##### --- install java --- #####
#
WORKDIR /opt/java
COPY    dev-tools/openjdk-16.0.1_linux-x64_bin.tar.gz .
RUN     tar xfvz openjdk-16.0.1_linux-x64_bin.tar.gz 

WORKDIR /opt
COPY    install-java.sh .
RUN     ./install-java.sh

RUN rm -rf openjdk-16.0.1_linux-x64_bin
RUN java -version
#
################################

##### --- install cmake --- #####
#
WORKDIR /usr/src

RUN set -xe; \
    wget https://cmake.org/files/v3.15/cmake-3.15.7-Linux-x86_64.tar.gz; \
    tar xvf cmake-3.15.7-Linux-x86_64.tar.gz; \
    cd cmake-3.15.7-Linux-x86_64; \
    ln -s $(pwd)/bin/cmake /usr/local/bin; \
    ln -s $(pwd)/bin/ctest /usr/local/bin; \
    cd ../; \
    rm -rf cmake-3.15.7-Linux-x86_64.tar.gz;
#
################################

###### --- install real-time --- #####
#
RUN echo 'kernel.sched_rt_runtime_us=-1' > /etc/sysctl.conf
RUN sysctl -w kernel.sched_rt_runtime_us=-1
#
################################

###### --- install arm cross compiler --- #####
#
RUN apt-get -y install p7zip-full
RUN apt-get --yes update && apt-get -y install g++-aarch64-linux-gnu
RUN apt-get --yes update && apt-get -y install gcc-aarch64-linux-gnu
#
################################

#--- DO NOT DELETE ---#
### Redo the symbolic links. Note: investigate whether there is an install option to set the symbolic links correctly
# RUN apt-get -y install mingw-w64
# COPY mingw-fix.tar.gz .
# RUN tar xvf mingw-fix.tar.gz
# RUN ./mingw-fix.sh

### ---- OpenGL ---- ###

###### --- install meson --- #####
RUN apt-get -y update &&  apt-get -y install python3 python3-pip python3-setuptools \
                       python3-wheel ninja-build

RUN pip3 install meson
#################################


###### --- install opengl stuff --- #####
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
   libgles2-mesa-dev
#################################

# required for meson bintray install
RUN pip3 install Mako

RUN apt-get -y update && apt-get -y install xterm x11-apps sudo

### for our windows environment
RUN sudo apt-get -y install gcc-mingw-w64-x86-64

# Current have two versions installed: 3.9 and 7. 7 supports mesa.
# TODO: update all to 7

RUN apt-get --yes remove gcc g++ && apt-get --yes purge --auto-remove gcc g++

RUN apt-get --yes update && apt-get --yes install software-properties-common && rm -rf /var/lib/apt/lists/*
RUN add-apt-repository ppa:ubuntu-toolchain-r/test 
RUN apt-get --yes update && apt-get --yes install gcc-11 g++-11

RUN ln -s /usr/bin/g++-11          /usr/bin/g++
RUN ln -s /usr/bin/gcc-11          /usr/bin/gcc
RUN ln -s /usr/bin/gcc-ar-11       /usr/bin/gcc-ar
RUN ln -s /usr/bin/gcc-nm-11       /usr/bin/gcc-nm
RUN ln -s /usr/bin/gcc-ranlib-11   /usr/bin/gcc-ranlib
RUN ln -s /usr/bin/gcc-cov-11      /usr/bin/gcc-cov
RUN ln -s /usr/bin/gcc-cov-dump-11 /usr/bin/gcc-cov-dump
RUN ln -s /usr/bin/gcc-cov-tool-11 /usr/bin/gcc-cov-tool

RUN ln -s /usr/bin/x86_64-linux-gnu-g++-11          /usr/bin/x86_64-linux-gnu-g++
RUN ln -s /usr/bin/x86_64-linux-gnu-gcc-11          /usr/bin/x86_64-linux-gnu-gcc
RUN ln -s /usr/bin/x86_64-linux-gnu-gcc-ar-11       /usr/bin/x86_64-linux-gnu-gcc-ar
RUN ln -s /usr/bin/x86_64-linux-gnu-gcc-nm-11       /usr/bin/x86_64-linux-gnu-gcc-nm
RUN ln -s /usr/bin/x86_64-linux-gnu-gcc-ranlib-11   /usr/bin/x86_64-linux-gnu-gcc-ranlib
RUN ln -s /usr/bin/x86_64-linux-gnu-gcc-cov-11      /usr/bin/x86_64-linux-gnu-gcc-cov
RUN ln -s /usr/bin/x86_64-linux-gnu-gcc-cov-dump-11 /usr/bin/x86_64-linux-gnu-gcc-cov-dump
RUN ln -s /usr/bin/x86_64-linux-gnu-gcc-cov-tool-11 /usr/bin/x86_64-linux-gnu-gcc-cov-tool

RUN g++ --version

RUN ln -s /usr/bin/clang++-10 /usr/bin/clang++
RUN ln -s /usr/bin/clang-10 /usr/bin/clang

RUN apt-get -y update && apt-get -y install sshpass

RUN apt-get -y update && apt-get -y install rsync tzdata
ENV TZ=America/Chicago

RUN apt-get -y update && apt-get -y install libfmt-dev 

RUN apt-get --yes update && DEBIAN_FRONTEND="noninteractive" apt-get --yes install make
WORKDIR /usr/src
#
#    git clone https://github.com/vim/vim.git; \
#    cd vim/src; \
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
      --disable-desktop-database-update; \
    make -j$(nproc); \
    make install; 

COPY ConanExtension.py /usr/local/lib/python3.8/dist-packages
COPY Colorcodes.py /usr/local/lib/python3.8/dist-packages
# COPY mosquitto.conf /etc/mosquitto

###### --- install for PlantUML Diagrams Only (for x86_64 platforms only) --- #####
#
COPY dev-tools/plantuml.jar /usr/bin
COPY buildUML.sh /usr/bin
#
######

##### --- install conan --- #####
#
WORKDIR /opt
RUN apt-get -qq update && apt-get -qq -y install gdb && pip3 install --upgrade pip && \
   pip3 install markupsafe==2.0.1


COPY dev-tools/conan-1.43.tar.gz .
RUN set -xe; \
   tar -xf conan-1.43.tar.gz; \  
   cd conan; \
   vim conans/client/build/cmake.py -c "let @l=\"329GIreturn \<Esc>\" | argdo normal @l | ZZ"; \
   vim conans/client/build/cmake.py -c "let @l=\"291GA 0\<Esc>2jIreturn \<Esc>\" | argdo normal @l | ZZ"; \
   vim conans/client/build/cmake.py -c "let @l=\"233Goretcode = 0\<Esc>14jIretcode = \<Esc>\$i, ignore_errors=True\<Esc>jI\<Enter>        return retcode\<Enter>\<Esc>\" | argdo normal @l | ZZ"; \
   pip3 install -e .;

#
################################

###### --- install for nvim --- #####
#
#  Do not install until YouCompleteMe integrates with nvim
#
# RUN wget --content-disposition https://github.com/neovim/neovim/releases/download/v0.7.0/nvim-linux64.deb
# RUN apt --yes install ./nvim-linux64.deb
#
######

###### --- install for CMake Modules --- #####
#
WORKDIR /opt/modules
COPY modules .
#
######

###### --- Supports Running GTest on ARM Boards --- #####
#
ENV BOARD="10.1.10.1"
#
######


RUN echo ">*** BASE FINISHED ***<"
