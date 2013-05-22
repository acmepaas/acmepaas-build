#!/bin/bash

# This script should make an effort to be idempotent.
set -ex

mkdir -p /usr/local/acmepaas
cd /usr/local/acmepaas

# Use oracle-java.
apt-get purge openjdk*
add-apt-repository ppa:webupd8team/java
apt-get update
apt-get install oracle-java7-installer
 
# package deps
apt-get -y install maven2 autoconf make gcc cpp patch python-dev git libtool gzip libghc-zlib-dev libcurl4-openssl-dev git-core openssh-server openssh-client autotools-dev automake cdbs g++ zlib1g-dev python-setuptools

if [ -d mesos ]
then
	cd mesos
	git pull origin trunk
else
	git clone https://github.com/apache/mesos.git
	cd mesos
fi
./bootstrap && ./configure --with-included-zookeeper && make && make install
cd src/python
python setup.py install
cd ../../..
 
export MESOS_NATIVE_LIBRARY=/usr/local/lib/libmesos.so
if [ -d chronos ]
then
	cd chronos
	git pull origin master
else
	git clone https://github.com/airbnb/chronos.git
	cd chronos
fi
mvn -DskipTests=true package
