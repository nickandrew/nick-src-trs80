# Installation instructions

The commands here are in bin/root-setup.sh which can be run to do the setup
in one command. This document explains what it does and why.

## system packages (ubuntu)

Make sure you have development prereqs installed:

```
sudo apt-get -y install make gcc g++ bison indent sdcc libreadline-dev libx11-dev groff html2text rsync
```

## Python virtual environment

```
python3 -m venv venv
source venv/bin/activate
pip3 install -r requirements.txt
```

## Other packages

### zmac

Build zmac from source. The "nick" branch contains necessary fixes to assemble
the assembler dialect used in this repository.

```
mkdir -p ~/GIT ~/bin
cd ~/GIT
git clone https://github.com/gp48k/zmac.git
cd zmac
git checkout -b nick origin/nick
cd src
make
cp zmac ~/bin/
```

### xtrs

Xtrs is no longer packaged in Ubuntu, so we build the latest from source.

```
cd ~/GIT
git clone https://github.com/TimothyPMann/xtrs.git
cd xtrs
make
cp xtrs mkdisk hex2cmd ~/bin/
```

Or https://github.com/nickandrew/xtrs.git
