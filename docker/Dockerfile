#
# Eris - Dockerfile
#
# TODO - Set your primary_account and primary_account_key in c3d-config.json
#
# # Build
# sudo docker build -t eris .
#
# # Run
# docker run -i -p 5000:5000 -p 30302:30302 -p 51413:51413 -t eris
#
# # Using boot2docker on OS X, open ports with :
# VBoxManage controlvm boot2docker-vm natpf1 "eth,tcp,127.0.0.1,5000,,5000"
# VBoxManage controlvm boot2docker-vm natpf1 "eth,tcp,127.0.0.1,30302,,30302"
#
# # Interactive
# docker run -i -t eris -
#

FROM ubuntu:14.04
MAINTAINER caktux

ENV DEBIAN_FRONTEND noninteractive

EXPOSE 5000
EXPOSE 30302

RUN apt-get update --fix-missing -y && apt-get upgrade -y && apt-get dist-upgrade -y

#
# Install dependencies
#

RUN apt-get install --fix-missing -y software-properties-common ntp apt-utils git sudo ssh openssh-server vim screen inotify-tools supervisor
RUN apt-get install --fix-missing -y build-essential g++-4.8 automake libtool unzip cmake libncurses5-dev
RUN apt-get install --fix-missing -y libgmp-dev libgmp3-dev libboost-all-dev libleveldb-dev yasm libminiupnpc-dev
RUN apt-get install --fix-missing -y qtbase5-dev qt5-default qtdeclarative5-dev libqt5webkit5-dev
RUN apt-get install --fix-missing -y curl transmission-daemon && service transmission-daemon stop && update-rc.d -f transmission-daemon remove

# Ruby
RUN \curl -L https://get.rvm.io | bash -s stable --ruby
RUN /bin/bash -l -c "rvm requirements"
RUN /bin/bash -l -c "rvm install 2.0"
RUN /bin/bash -l -c "gem install bundler --no-ri --no-rdoc"

RUN mkdir /eris

# Build dependencies for Ethereum
RUN mkdir /eris/cryptopp562 && cd /eris/cryptopp562 && wget http://www.cryptopp.com/cryptopp562.zip && unzip cryptopp562.zip && make -j $(cat /proc/cpuinfo | grep processor | wc -l)

# JSON-RPC support
RUN apt-get install --fix-missing -y libcurl4-openssl-dev
RUN mkdir /eris/jsonrpc && cd /eris/jsonrpc && git clone git://github.com/cinemast/libjson-rpc-cpp.git && cd libjson-rpc-cpp/build && cmake .. && make -j $(cat /proc/cpuinfo | grep processor | wc -l) && make install && ldconfig

# Clone latest Ethereum
RUN cd /eris && git clone https://github.com/project-douglas/cpp-ethereum.git

# Checkout branch, hard to update container that way...
cd /eris/cpp-ethereum && git pull && git checkout develop

# Hot patch leveldb
RUN cd /eris/cpp-ethereum && sed -ri "s/Status OK/Status Ok/g" /usr/include/leveldb/status.h

# Build Ethereum
RUN mkdir /eris/cpp-ethereum/cpp-ethereum-build && cd /eris/cpp-ethereum/cpp-ethereum-build && cmake /eris/cpp-ethereum/cpp-ethereum-build -DCMAKE_BUILD_TYPE=Eris -DHEADLESS=1 /eris/cpp-ethereum && make -j $(cat /proc/cpuinfo | grep processor | wc -l)

# Install Eris
RUN cd /eris && git clone https://github.com/project-douglas/eris.git
RUN cd /eris/eris && git pull && /bin/bash -l -c "bundle install --system"

# TODO - edit c3d-config.json
RUN mkdir /.epm
ADD c3d-config.json /.epm/

CMD ["-l", "-c", "foreman start"]
ENTRYPOINT ["/bin/bash"]
WORKDIR /eris/eris
