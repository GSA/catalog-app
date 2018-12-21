set -o errexit
set -o pipefail
set -o nounset

python_home=/usr/local/lib/python2.7.10
export LD_LIBRARY_PATH="$python_home/lib"

venv="${1:-/usr/lib/ckan}"
pip="$venv/bin/pip"

# create virtual_env
source /usr/lib/ckan/bin/activate

# Install development dependencies of extensions
# TODO extensions should declare runtime dependencies in setup.py
EXTENSIONS=$(cat requirements.txt | grep -o "egg=.*" | cut -f2- -d'=')

# install/setup each extension individually
for extension in $EXTENSIONS; do
    if [ -f $venv/src/$extension/requirements.txt ]; then
        "$pip" install -r $venv/src/$extension/requirements.txt
    elif [ -f $venv/src/$extension/pip-requirements.txt ]; then
        "$pip" install -r $venv/src/$extension/pip-requirements.txt
    fi
done
