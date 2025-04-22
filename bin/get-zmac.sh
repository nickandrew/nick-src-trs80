#!/bin/bash
#  Retrieve and install zmac

set -e

mkdir -p ~/bin

mkdir -p ~/GIT
cd ~/GIT

git clone -b nick http://github.com/nickandrew/zmac.git
cd zmac/src
make && cp zmac ~/bin/zmac
