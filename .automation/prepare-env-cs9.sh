#!/bin/bash -xe

# DNF core plugins are installed in the official CS9 container image
dnf install -y dnf-plugins-core

# Install oVirt repositories
dnf copr enable -y ovirt/ovirt-master-snapshot
yum install -y ovirt-release-master

# Install required packages
dnf config-manager --enable crb
dnf install -y \
    createrepo_c \
    dnf-utils \
    gzip \
    java-11-openjdk-devel \
    maven \
    rpm-build \
    sed \
    tar
