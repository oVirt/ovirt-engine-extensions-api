#!/bin/bash -xe

source $(dirname "$(readlink -f "$0")")/build-srpm.sh

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
