FROM ubuntu:18.04

# ----------------------------
# Setup Ubuntu
# refer to: https://www.usagi1975.com/201912212117/
# ----------------------------
ARG username=vsomeip
ARG homedir=/home/${username}

# apt-get
RUN apt-get update
RUN apt-get install -y --no-install-recommends \
  sudo curl wget apt-transport-https gnupg \
  ca-certificates cmake\
  gcc build-essential git vim unzip
RUN apt-get upgrade

# apt
RUN apt update
RUN apt upgrade

# make user
RUN echo "root:root" | chpasswd && \
    adduser --disabled-password --gecos "" "${username}" && \
    echo "${username}:${username}" | chpasswd && \
    echo "%${username}    ALL=(ALL)   NOPASSWD:    ALL" >> /etc/sudoers.d/${username} && \
    chmod 0440 /etc/sudoers.d/${username} 
    
# login as user
USER $username
WORKDIR ${homedir}


# ----------------------------
# Setup vsomeip
# ----------------------------

RUN mkdir ${homedir}/dev

# Boost
RUN sudo apt install libboost-all-dev -y

# libsystemd
RUN sudo apt-get install libudev-dev libsystemd-dev -y

# Doxygen
RUN sudo apt-get install doxygen -y

# graphviz
RUN sudo apt install graphviz -y

# asciidoc
#RUN sudo apt install asciidoc -y

# RUN sudo chown ${username} ${homedir} -R
# RUN sudo chmod 777 ${homedir}
# RUN sudo chmod 777 ${homedir}/dev

# dlt-daemon
WORKDIR ${homedir}/dev
RUN git clone https://github.com/COVESA/dlt-daemon -b v2.18.8
WORKDIR ${homedir}/dev/dlt-daemon
RUN mkdir build
WORKDIR ${homedir}/dev/dlt-daemon/build
RUN cmake ..
RUN make
RUN sudo make install
RUN sudo ldconfig



# vsomeip
WORKDIR ${homedir}/dev
RUN git clone https://github.com/COVESA/vsomeip -b 3.1.20.3
WORKDIR ${homedir}/dev/vsomeip
RUN mkdir build
WORKDIR ${homedir}/dev/vsomeip/build
RUN cmake ..
RUN make
RUN sudo make install
RUN sudo ldconfig


# vsomeip hello_world
WORKDIR ${homedir}/dev/vsomeip/build
RUN cmake --build . --target hello_world && \
    cd ./examples/hello_world  && \
    make  
WORKDIR ${homedir}/dev/vsomeip/build/examples/hello_world
# RUN VSOMEIP_CONFIGURATION=../helloworld-local.json \
#     VSOMEIP_APPLICATION_NAME=hello_world_service \
#     ./hello_world_service
# RUN VSOMEIP_CONFIGURATION=../helloworld-local.json \
#     VSOMEIP_APPLICATION_NAME=hello_world_client \
#     ./hello_world_client

