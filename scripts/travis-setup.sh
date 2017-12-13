#!/bin/bash
set -e
set -x


if [[ $TRAVIS_BRANCH != "master" && $TRAVIS_BRANCH != "bulk" && $TRAVIS_PULL_REQUEST == "false" && $TRAVIS_REPO_SLUG == "$MY_TRAVIS_REPO_SLUG" ]]
then
    echo ""
    echo "Setup is skipped for pushes to the main bioconda-recipes repo."
    echo ""
    exit 0
fi

for dir in . recipes
do
    if [ -e $dir/meta.yaml ]
    then
        echo "Recipe $dir/meta.yaml found in invalid location."
        echo "Recipes must be stored in a subfolder of the recipes directory."
        exit 1
    fi
done

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

pip install pyyaml
sudo mkdir /anaconda

sudo chown -R $USER /opt/anaconda3
sudo chown -R $USER /anaconda

wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
bash miniconda.sh -b -p /anaconda3
export PATH="/anaconda3/bin:$PATH"
hash -r
conda config --set always_yes yes --set changeps1 no
conda config --add channels r
conda config --add channels conda-forge
conda config --add channels bioconda

/anaconda/bin/conda index /anaconda/conda-bld/linux-64 /anaconda/conda-bld/osx-64
/anaconda/bin/conda config --add channels file://anaconda/conda-bld
/anaconda/bin/conda install -y r-base r-essentials openjdk perl bioconductor-biobase nodejs
/anaconda/bin/npm install -g marked-man
