#!/bin/bash -xe

# TODO: Replace with ovirt-release-master RPM installation
REPO_FILE="/etc/yum.repos.d/virt8s-ovirt-45-el9s.repo"
printf "[ovirt-master-centos-stream-ovirt45-testing]\n" > ${REPO_FILE}
printf "name=CentOS Stream 9 - oVirt 4.5 - testing\n" >> ${REPO_FILE}
printf "baseurl=https://buildlogs.centos.org/centos/9-stream/virt/x86_64/ovirt-45/\n" >> ${REPO_FILE}
printf "gpgcheck=0\n" >> ${REPO_FILE}
printf "enabled=1\n" >> ${REPO_FILE}
printf "module_hotfixes=1" >> ${REPO_FILE}

# Install required packages
dnf install -y dnf-plugins-core
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
