FROM debian:trixie-slim

ARG USERNAME_CONTAINER
ARG USER_UID_CONTAINER
ARG TARGETPLATFORM

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    bsdextrautils \
    ca-certificates \
    curl \
    git \
    gpg \
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

# 1. Create the user FIRST
RUN useradd -m -u ${USER_UID_CONTAINER} -s /bin/zsh ${USERNAME_CONTAINER} \
    && echo "${USERNAME_CONTAINER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# 2. Prep /nix with correct ownership so the user can install into it
#    (single-user Nix installs need /nix owned by the installing user)
RUN groupadd -r nixbld \
    && mkdir -m 0755 /nix \
    && chown ${USERNAME_CONTAINER} /nix

# 3. SSH: harden sshd config (no root login, no password auth)
RUN mkdir -p /home/${USERNAME_CONTAINER}/.ssh \
    && chmod 700 /home/${USERNAME_CONTAINER}/.ssh \
    && chown ${USERNAME_CONTAINER}:${USERNAME_CONTAINER} /home/${USERNAME_CONTAINER}/.ssh \
    && sed -i \
        -e 's/^#\?PermitRootLogin.*/PermitRootLogin no/' \
        -e 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' \
        -e 's/^#\?PubkeyAuthentication.*/PubkeyAuthentication yes/' \
        /etc/ssh/sshd_config \
    && echo "AllowUsers ${USERNAME_CONTAINER}" >> /etc/ssh/sshd_config

RUN if [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
      mkdir -p /etc/nix && \
      echo "filter-syscalls = false" >> /etc/nix/nix.conf; \
    fi

# 4. Switch to the user for the rest of the Nix setup
USER ${USERNAME_CONTAINER}
WORKDIR /home/${USERNAME_CONTAINER}

RUN mkdir -p /home/${USERNAME_CONTAINER}/.ssh
RUN chown -R ${USERNAME_CONTAINER}:${USERNAME_CONTAINER} /home/${USERNAME_CONTAINER}/.ssh
RUN chmod 700 /home/${USERNAME_CONTAINER}/.ssh

# 5. Install Nix AS the user (writes into /home/$USERNAME_CONTAINER/.nix-profile)
RUN curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | sh -s -- --no-daemon --yes

ENV PATH="/home/${USERNAME_CONTAINER}/.nix-profile/bin:${PATH}"


# 6. Copy shell.nix with correct ownership and install packages as the user
COPY --chown=${USERNAME_CONTAINER}:${USERNAME_CONTAINER} shell.nix /home/${USERNAME_CONTAINER}/shell.nix
RUN . /home/${USERNAME_CONTAINER}/.nix-profile/etc/profile.d/nix.sh && \
    nix-env -if /home/${USERNAME_CONTAINER}/shell.nix --extra-experimental-features nix-command

RUN git clone --branch devcontainer \
    https://github.com/hgoumner/config_repo.git /home/${USERNAME_CONTAINER}/config_repo

USER root

CMD ["/usr/sbin/sshd", "-D", "-e"]
