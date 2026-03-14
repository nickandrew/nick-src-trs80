#!/bin/bash
#
#  Set up initial python development environment

set -e
set -v

python3 -m venv venv
source venv/bin/activate
pip3 install -r requirements.txt
