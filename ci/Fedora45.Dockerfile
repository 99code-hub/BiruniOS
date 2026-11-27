FROM fedora:45

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    BIRUNIOS_VERSION=0.1.0 \
    FEDORA_RELEASE=45

RUN dnf -y install \
      lorax-lmc-novirt \
      pykickstart \
      livecd-tools \
      anaconda-tui \
      createrepo_c \
      rpm-build \
      cmake \
      gcc-c++ \
      make \
      qt6-qtbase-devel \
      git \
      tar \
      xz \
      findutils \
      coreutils \
      util-linux \
      which \
      hostname \
      shadow-utils \
    && dnf clean all \
    && rm -rf /var/cache/dnf

WORKDIR /workspace
ENTRYPOINT ["/bin/bash", "/workspace/scripts/build-iso.sh"]
