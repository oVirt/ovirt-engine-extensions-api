#!/bin/bash -xe

# git hash of current commit should be passed as the 1st paraameter
if [ "${GITHUB_SHA}" == "" ]; then
  GIT_HASH=$(git rev-list HEAD | wc -l)
else
  GIT_HASH=$(git rev-parse --short $GITHUB_SHA)
fi

# Directory, where build artifacts will be stored, should be passed as the 1st parameter
ARTIFACTS_DIR=${1:-exported-artifacts}

# Prepare the version string (with support for SNAPSHOT versioning)
VERSION=$(mvn help:evaluate  -q -DforceStdout -Dexpression=project.version)
VERSION=${VERSION/-SNAPSHOT/-0.${GIT_HASH}.$(date +%04Y%02m%02d%02H%02M)}
IFS='-' read -ra VERSION <<< "$VERSION"
RELEASE=${VERSION[1]-1}

# Prepare source archive
[[ -d ${HOME}/rpmbuild/SOURCES ]] || mkdir -p ${HOME}/rpmbuild/SOURCES
git archive --format=tar HEAD | gzip -9 > ${HOME}/rpmbuild/SOURCES/ovirt-engine-extensions-api-$VERSION.tar.gz

# Set version and release
sed \
    -e "s|@VERSION@|${VERSION}|g" \
    -e "s|@RELEASE@|${RELEASE}|g" \
    < ovirt-engine-extensions-api.spec.in \
    > ovirt-engine-extensions-api.spec

# Build source package
rpmbuild \
    --define "_topmdir $HOME/rpmbuild" \
    --define "_rpmdir $HOME/rpmbuild" \
    -bs ovirt-engine-extensions-api.spec
