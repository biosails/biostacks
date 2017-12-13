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

sudo chown -R $USER /opt/anaconda3

wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh --quiet -O miniconda.sh
bash miniconda.sh -b -p /home/travis/anaconda3
export PATH="/home/travis/anaconda3/bin:$PATH"
hash -r
conda config --set always_yes yes --set changeps1 no
conda config --add channels r
conda config --add channels conda-forge
conda config --add channels bioconda
conda config --add channels nyuad-cgsb

conda index /home/travis/anaconda3/conda-bld/linux-64 /home/travis/anaconda3/conda-bld/osx-64
conda config --add channels file://home/travis/anaconda3/conda-bld
conda install -y r-base r-essentials openjdk perl bioconductor-biobase nodejs
npm install -g marked-man
