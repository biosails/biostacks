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

export PATH=/anaconda/bin:$PATH

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
conda install -y conda-build-all
conda-build-all recipes --inspect-channels nyuad-cgsb $UPLOAD_ARG
ls -lahR $CONDA_BLD_PATH

cp Dockerfile /opt/anaconda3
cd /opt/anaconda3

docker images
set +x
