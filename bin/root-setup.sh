#!/bin/bash
#
#  Do this as root, to prepare the host
#
#  builder script requires:
#    sdcc zmac
#  sdcc build requires:
#    make gcc g++ bison
#  zmac build requires:
#    make gcc g++
#  development requires:
#    indent
#  converting .ihx files to .cmd requires:
#    xtrs - install from source
#  making xtrs:
#    html2text
#    pod2pdf - maybe

set -e
set -v

GITDIR=$HOME/GIT2

sudo apt-get -y install make gcc g++ bison indent sdcc
sudo apt-get -y install libreadline-dev libx11-dev groff html2text rsync

mkdir -p $GITDIR ~/bin
cd $GITDIR
git clone https://github.com/nickandrew/zmac.git
cd zmac
git checkout -b nick origin/nick
cd src
make
cp zmac ~/bin/

# Xtrs

cd $GITDIR
git clone https://github.com/TimothyPMann/xtrs.git
cd xtrs
make
cp xtrs mkdisk hex2cmd ~/bin/


