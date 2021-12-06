#!/bin/bash -xe

# Install oVirt repositories
rpm --import https://download.copr.fedorainfracloud.org/results/ovirt/ovirt-master-snapshot/pubkey.gpg
dnf install -y \
    --repofrompath=ovirt-master-snapshot,https://download.copr.fedorainfracloud.org/results/ovirt/ovirt-master-snapshot/centos-stream-8-x86_64/ \
    ovirt-release-master

# Install required packages
dnf config-manager --enable powertools
dnf module enable -y pki-deps javapackages-tools
dnf install -y \
    createrepo_c \
    dnf-utils \
    gzip \
    java-11-openjdk-devel \
    maven \
    rpm-build \
    sed \
    tar
