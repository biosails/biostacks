#!/bin/bash
set -euo pipefail
# Set some defaults
set +u
[[ -z $DOCKER_ARG ]] && DOCKER_ARG=""
[[ -z $TRAVIS ]] && TRAVIS="false"
[[ -z $BIOCONDA_UTILS_LINT_ARGS ]] && BIOCONDA_UTILS_LINT_ARGS=""
[[ -z $RANGE_ARG ]] && RANGE_ARG="--git-range master HEAD"
[[ -z $DISABLE_BIOCONDA_UTILS_BUILD_GIT_RANGE_CHECK  ]] && DISABLE_BIOCONDA_UTILS_BUILD_GIT_RANGE_CHECK="false"
[[ -z $SKIP_LINTING ]] && SKIP_LINTING=false
[[ -z $UPLOAD_ARG ]] && UPLOAD_ARG=""
set -u

if [[ $TRAVIS_BRANCH != "master" && $TRAVIS_BRANCH != "bulk" && $TRAVIS_PULL_REQUEST == "false" && $TRAVIS_REPO_SLUG == "$MY_TRAVIS_REPO_SLUG" ]]
then
    echo ""
    echo "Tests are skipped for pushes to the main bioconda-recipes repo."
    echo "If you have opened a pull request, please see the full tests for that PR."
    echo "See https://bioconda.github.io/build-system.html for details"
    echo ""
    exit 0
fi


# TODO Add another upload
if [[ ( $TRAVIS_BRANCH == "master" || $TRAVIS_BRANCH == "bulk" ) && "$TRAVIS_PULL_REQUEST" == "false" && $TRAVIS_REPO_SLUG == "$MY_TRAVIS_REPO_SLUG" ]]
then
        UPLOAD_ARG="--upload-channels nyuad-cgsb "
fi


if [[ $DISABLE_BIOCONDA_UTILS_BUILD_GIT_RANGE_CHECK == "true" ]]
then
    echo
    echo "DISABLE_BIOCONDA_UTILS_BUILD_GIT_RANGE_CHECK is true."
    echo "A comprehensive check will be performed to see what needs to be built."
    RANGE_ARG=""
fi

set -x

export PATH=/home/travis/anaconda3/bin:$PATH
conda install -y conda-build-all
travis_wait 30 conda-build-all recipes --inspect-channels nyuad-cgsb $UPLOAD_ARG
ls -lahR $CONDA_BLD_PATH

echo "We should be building things now...."

cp Dockerfile /opt/anaconda3
cd /opt/anaconda3
travis_wait 30 docker build --build-arg CONDA_PKG='gencore_rnaseq-1.0-r3.4.1_1.tar.bz2'

docker images
set +x
