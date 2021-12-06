#!/bin/bash -xe

# git hash of current commit should be passed as the 1st paraameter
GIT_HASH=$1

# Directory, where build artifacts will be stored, should be passed as the 2nd parameter
ARTIFACTS_DIR=${2:-exported-artifacts}

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

# Install build dependencies
dnf builddep -y $HOME/rpmbuild/SRPMS/*src.rpm

# Build binary package
rpmbuild \
    --define "_topmdir $HOME/rpmbuild" \
    --define "_rpmdir $HOME/rpmbuild" \
    --rebuild $HOME/rpmbuild/SRPMS/*src.rpm

# Move RPMs to exported artifacts
[[ -d $ARTIFACTS_DIR ]] || mkdir -p $ARTIFACTS_DIR
find $HOME/rpmbuild -iname \*rpm | xargs mv -t $ARTIFACTS_DIR
