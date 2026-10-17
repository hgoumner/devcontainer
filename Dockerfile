FROM debian:trixie-slim

ARG USERNAME_CONTAINER
ARG USER_UID_CONTAINER
ARG TARGETPLATFORM

RUN dpkg --add-architecture amd64 \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    build-essential \
    bsdextrautils \
    ca-certificates \
    curl \
    git \
    gpg \
    libc6:amd64 \
    locales \
    make \
    ncurses-bin \
    openssh-server \
    stow \
    sudo \
    tar \
    ugrep \
    unzip \
    wget \
    xz-utils \
    zsh \
    && rm -rf /var/lib/apt/lists/* \
    && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
    && locale-gen

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

RUN mkdir -p /run/sshd

RUN useradd -m -u ${USER_UID_CONTAINER} -s /bin/zsh ${USERNAME_CONTAINER} \
    && echo "${USERNAME_CONTAINER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN groupadd -r nixbld \
    && mkdir -m 0755 /nix \
    && chown ${USERNAME_CONTAINER}:${USERNAME_CONTAINER} /nix

COPY zscaler.crt /usr/local/share/ca-certificates/zscaler.crt

RUN update-ca-certificates

RUN mkdir -p /home/${USERNAME_CONTAINER}/.ssh \
    && chmod 700 /home/${USERNAME_CONTAINER}/.ssh \
    && chown ${USERNAME_CONTAINER}:${USERNAME_CONTAINER} /home/${USERNAME_CONTAINER}/.ssh \
    && sed -i \
        -e 's/^#\?PermitRootLogin.*/PermitRootLogin no/' \
        -e 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' \
        -e 's/^#\?PubkeyAuthentication.*/PubkeyAuthentication yes/' \
        /etc/ssh/sshd_config \
    && echo "AllowUsers ${USERNAME_CONTAINER}" >> /etc/ssh/sshd_config

RUN mkdir -p /etc/nix

RUN echo "filter-syscalls = false" >> /etc/nix/nix.conf

USER ${USERNAME_CONTAINER}
WORKDIR /home/${USERNAME_CONTAINER}

RUN curl --proto '=https' --tlsv1.2 -L \
    https://nixos.org/nix/install \
    | sh -s -- --no-daemon --yes

ENV PATH="/home/${USERNAME_CONTAINER}/.nix-profile/bin:${PATH}"

RUN mkdir -p /home/${USERNAME_CONTAINER}/.config/nix && \
    printf '%s\n' \
      "experimental-features = nix-command flakes" \
      "http2 = false" \
      > /home/${USERNAME_CONTAINER}/.config/nix/nix.conf

COPY --chown=${USERNAME_CONTAINER}:${USERNAME_CONTAINER} flake.nix \
    /home/${USERNAME_CONTAINER}/flake.nix

RUN . /home/${USERNAME_CONTAINER}/.nix-profile/etc/profile.d/nix.sh && \
    cd /home/${USERNAME_CONTAINER} && \
    nix profile install .#dev-tools

RUN git clone --branch devcontainer \
    https://github.com/hgoumner/config_repo.git \
    /home/${USERNAME_CONTAINER}/config_repo

USER root

CMD ["/usr/sbin/sshd", "-D", "-e"]
