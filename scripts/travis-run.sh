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
# [[ -z $CONTAINER_NAMESPACE ]] && CONTAINER_NAMESPACE="nyuad_cgsb"
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


# determine recipes to build. If building locally, build anything that changed
# since master. If on travis, only build the commit range included in the push
# or the pull request.
if [[ $TRAVIS == "true" ]]
then
    RANGE="$TRAVIS_BRANCH HEAD"
    if [ $TRAVIS_PULL_REQUEST == "false" ]
    then
        if [ -z "$TRAVIS_COMMIT_RANGE" ]
        then
            RANGE="HEAD~1 HEAD"
        else
            RANGE="${TRAVIS_COMMIT_RANGE/.../ }"
        fi
    fi

    if [[ $TRAVIS_EVENT_TYPE == "cron" ]]
    then
        RANGE_ARG=""
        SKIP_LINTING=true
    else
        if [[ $TRAVIS_BRANCH == "bulk" ]]
        then
            if [[ $TRAVIS_PULL_REQUEST != "false" ]]
            then
                # pull request against bulk: only build additionally changed recipes
                git fetch origin $TRAVIS_BRANCH
                RANGE_ARG="--git-range $RANGE"
            else
                # push on bulk: consider all recipes and do not lint (the bulk update)!
                RANGE_ARG=""
                SKIP_LINTING=true
            fi
        else
            # consider only recipes that (a) changed since the last build
            # on master, or (b) changed in this pull request compared to the target
            # branch.
            RANGE_ARG="--git-range $RANGE"
        if [[ $TRAVIS_PULL_REQUEST_BRANCH == "bulk" ]]
            then
                SKIP_LINTING=true
            fi
        fi
    fi
fi

export PATH=/anaconda/bin:$PATH

# On travis we always run on docker for linux. This may not always be the case
# for local testing.
if [[ $TRAVIS_OS_NAME == "linux" && $TRAVIS == "true" ]]
then
    DOCKER_ARG="--docker --mulled-test"
fi

# When building master or bulk, upload packages to anaconda and quay.io.
# TODO Add another upload
if [[ ( $TRAVIS_BRANCH == "master" || $TRAVIS_BRANCH == "bulk" ) && "$TRAVIS_PULL_REQUEST" == "false" && $TRAVIS_REPO_SLUG == "$MY_TRAVIS_REPO_SLUG" ]]
then
    if [[ $TRAVIS_OS_NAME == "linux" ]]
    then
        UPLOAD_ARG="--anaconda-upload --mulled-upload-target $CONTAINER_NAMESPACE"
    else
        UPLOAD_ARG="--anaconda-upload"
    fi
else
    UPLOAD_ARG=""
    LINT_COMMENT_ARG=""
    if [[ $TRAVIS_OS_NAME == "linux" && $TRAVIS_PULL_REQUEST != "false" && -n "${GITHUB_TOKEN:-}" ]]
    then
        LINT_COMMENT_ARG="--push-comment --pull-request $TRAVIS_PULL_REQUEST"
    fi
    if [[ $SKIP_LINTING == "false"  ]]
    then
        set -x; bioconda-utils lint recipes config.yml $RANGE_ARG $BIOCONDA_UTILS_LINT_ARGS $LINT_COMMENT_ARG; set +x
    fi
fi


if [[ $DISABLE_BIOCONDA_UTILS_BUILD_GIT_RANGE_CHECK == "true" ]]
then
    echo
    echo "DISABLE_BIOCONDA_UTILS_BUILD_GIT_RANGE_CHECK is true."
    echo "A comprehensive check will be performed to see what needs to be built."
    RANGE_ARG=""
fi

set -x
pip install --upgrade  git+https://github.com/jerowe/bioconda-utils.git@develop
bioconda-utils build recipes config.yml $UPLOAD_ARG $DOCKER_ARG $BIOCONDA_UTILS_BUILD_ARGS $RANGE_ARG || echo "Build Failed!"
docker images
set +x
