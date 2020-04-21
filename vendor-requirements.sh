#!/bin/bash 

# This script installs some necessary .deb dependencies and then installs binary .whls for the packages
# specified in vendor-requirements.txt into the "vendor" directory.

# Install any packaged dependencies for our vendored packages
sudo apt-get -y update
sudo apt-get -y install swig build-essential python-dev libssl-dev libgeos-dev

# Cache wheels for requirements
pip wheel -r requirements-freeze.txt -w vendor
