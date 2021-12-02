#!/bin/bash -xe

# Build RPMs
mvn help:evaluate -Dexpression=project.version -gs "$MAVEN_SETTINGS" # downloads and installs the necessary jars

# Prepare the version string (with support for SNAPSHOT versioning)
VERSION=$(mvn help:evaluate -Dexpression=project.version -gs "$MAVEN_SETTINGS" 2>/dev/null| grep -v "^\[")
VERSION=${VERSION/-SNAPSHOT/-0.$(git rev-list HEAD | wc -l).$(date +%04Y%02m%02d%02H%02M)}
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

rpmbuild \
    --define "_topmdir $PWD/rpmbuild" \
    --define "_rpmdir $PWD/rpmbuild" \
    -ba --nodeps ovirt-engine-extensions-api.spec

# Move RPMs to exported artifacts
[[ -d exported-artifacts ]] || mkdir -p exported-artifacts
find rpmbuild -iname \*rpm | xargs mv -t exported-artifacts
