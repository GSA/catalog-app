#!/bin/bash
#
# Install script used in production environments. This initializes the virtual
# environment and then installs frozen package versions from
# requirements-freeze.txt

set -o errexit
set -o pipefail
set -o nounset

# Default umask with hardening is 0027 which causes all kinds of headaches.
# Make sure files are installed world readable.
umask 0022

venv="${1:-/usr/lib/ckan}"
python_home=${2:-/usr/local/lib/python2.7.10}
export LD_LIBRARY_PATH="$python_home/lib"

pip="$venv/bin/pip"

# create virtual_env
virtualenv_opts="--no-site-packages"
if [ -f "$python_home/bin/python" ]; then
    virtualenv_opts+=" -p $python_home/bin/python"
fi
virtualenv "$venv" $virtualenv_opts

# upgrade pip and setuptools
"$pip" install -U pip==8.1.1 setuptools==40.5.0

# install ckan core + ckan extensions
"$pip" install -r requirements-freeze.txt
