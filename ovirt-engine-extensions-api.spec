# The version macro to be redefined by Jenkins build when needed
%define project_version 1.0.0-SNAPSHOT
%define project_release 1

%{!?_version: %define _version %{project_version}}
%{!?_release: %define _release %{project_release}}
%define mvn_sed sed -e 's/mvn(\\([^)]*\\))\\( [>=<]\\{1,2\\} [^ ]\\{1,\\}\\)\\{0,1\\}/\\1/g'
%{!?_licensedir:%global license %doc}


Name:		ovirt-engine-extensions-api
Version:	%{_version}
Release:	%{_release}%{?dist}
Summary:	oVirt engine extensions API
Group:		%{ovirt_product_group}
License:	ASL 2.0
URL:		http://www.ovirt.org
Source0:	%{name}-%{version}.tar.gz

# We need to disable automatic generation of "Requires: java-headless >= 1:11"
# by xmvn, becase JDK 11 doesn't provide java-headless artifact, but it
# provides java-11-headless.
AutoReq:	no

BuildArch:	noarch

BuildRequires:	java-11-openjdk-devel
BuildRequires:	maven-local
BuildRequires:	mvn(org.apache.maven.plugins:maven-compiler-plugin)
BuildRequires:	mvn(org.apache.maven.plugins:maven-release-plugin)
BuildRequires:	mvn(org.apache.maven.plugins:maven-source-plugin)

# On EL8 maven-javadoc-plugin has been merged into xmvn, but on Fedora
# we still need to require it
%if 0%{?fedora} >= 30
BuildRequires:	mvn(org.apache.maven.plugins:maven-javadoc-plugin)
%endif

Requires:	java-11-openjdk-headless >= 1:11.0.0
Requires:	javapackages-filesystem


%description
%{name} provides classes that define API for oVirt engine extensions


%package javadoc
Summary:	oVirt engine extensions API documentation
Group:		%{ovirt_product_group}


%description javadoc
oVirt engine extensions API documentation


%prep
%setup -c -q

# On EL8 maven-javadoc-plugin has been merged into xmvn, so we need to remove
# reference to it from pom.xml
%if 0%{?rhel} >= 8
%pom_remove_plugin :maven-javadoc-plugin pom.xml
%endif


%build
# Necessary to override the default for xmvn, which is JDK 8
export JAVA_HOME="/usr/lib/jvm/java-11-openjdk"

%mvn_build


%install
%mvn_install


%files -f .mfiles
%license LICENSE
%dir %{_javadir}/%{name}


%files javadoc -f .mfiles-javadoc


%changelog
* Fri Feb 7 2020 Martin Perina <mperina@redhat.com> 1.0.0-1
- Extracted from ovirt-engine into standalone project
- Bump requirements to JDK 11
