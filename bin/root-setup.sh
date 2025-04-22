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
#    xtrs

apt-get install make gcc g++ bison indent sdcc xtrs
