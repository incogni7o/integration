#!/bin/bash
set -e

source ".travis/release.properties"

function do_regular_build() {
    echo "Performing regular build..."

    setup

    mvn clean verify \
            -P release \
            --settings .travis/release.settings.xml
}

function do_release() {
    echo "Performing (almost) release ${releaseVersion}' ..."

    setup

    mvn release:clean release:prepare -U -e -B \
            --settings .travis/release.settings.xml \
            -DreleaseVersion=${releaseVersion} \
            -DdevelopmentVersion=${developmentVersion}
}

function setup() {

    # *** GIT
    git config user.name "${GITHUB_USERNAME}"
    git config user.email "${GITHUB_EMAIL}"

    # changing file flag to executable should not be treated as a change
    git config --add core.filemode false

    # Travis CI works in detached mode so we have to fix it
    git checkout ${TRAVIS_BRANCH}
    git reset --hard ${TRAVIS_COMMIT}

    # *** PGP
    set +e
    if [ ! -z "${GPG_SECRET_KEYS}" ]; then echo ${GPG_SECRET_KEYS} | base64 --decode | ${GPG_EXECUTABLE} --import; fi
    if [ ! -z "${GPG_OWNERTRUST}" ]; then echo ${GPG_OWNERTRUST} | base64 --decode | ${GPG_EXECUTABLE} --import-ownertrust; fi
    set -e

    # *** SSH AGENT
    # start the ssh-agent in the background if not already started
    # and add the private key used to commit to GitHub
    state=$(ssh-add -l >| /dev/null 2>&1; echo $?)
    if ([ ! "${SSH_AUTH_SOCK}" ] || [ ${state} == 2 ]); then
        eval "$(ssh-agent -s)"
    fi

    echo "${SSH_SECRET_KEYS}" | base64 --decode | ssh-add -

    # *** DECODE BASE64 ENCODED ENV VARIABLES
    # due to the way how Travis sets the environment variables
    # most of variables are base54 encoded, so here we decode them
    if [ ! -z "${OSS_SONATYPE_PASSWORD}" ]; then OSS_SONATYPE_PASSWORD=`echo ${OSS_SONATYPE_PASSWORD} | base64 --decode`; export OSS_SONATYPE_PASSWORD; fi
    if [ ! -z "${OSS_SONATYPE_USER}" ]; then OSS_SONATYPE_USER=`echo ${OSS_SONATYPE_USER} | base64 --decode`; export OSS_SONATYPE_USER; fi
    if [ ! -z "${GPG_PASSPHRASE}" ]; then GPG_PASSPHRASE=`echo ${GPG_PASSPHRASE} | base64 --decode`; export GPG_PASSPHRASE; fi
}

# Determine the build type and perform it
pattern="(^[[:blank:]]*)Release[[:blank:]]+${releaseVersion}([[:blank:]]|$)"
if [[ "${TRAVIS_COMMIT_MESSAGE}" =~ ${pattern} ]]; then
    do_release
else
    do_regular_build
fi




