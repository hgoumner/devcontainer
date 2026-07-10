FROM debian:bookworm-slim

ARG USERNAME_CONTAINER
ARG USER_UID_CONTAINER

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl xz-utils ca-certificates zsh sudo ncurses-bin locales \
    && rm -rf /var/lib/apt/lists/* \
    && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
    && locale-gen

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# RUN curl -o /tmp/kitty.terminfo \
#     https://raw.githubusercontent.com/kovidgoyal/kitty/master/terminfo/kitty.terminfo \
#     && tic -x -o /usr/share/terminfo /tmp/kitty.terminfo \
#     && rm /tmp/kitty.terminfo

# 1. Create the user FIRST
RUN useradd -m -u ${USER_UID_CONTAINER} -s /bin/zsh ${USERNAME_CONTAINER} \
    && echo "${USERNAME_CONTAINER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# 2. Prep /nix with correct ownership so the user can install into it
#    (single-user Nix installs need /nix owned by the installing user)
RUN groupadd -r nixbld \
    && mkdir -m 0755 /nix \
    && chown ${USERNAME_CONTAINER} /nix

# 3. Switch to the user for the rest of the Nix setup
USER ${USERNAME_CONTAINER}
WORKDIR /home/${USERNAME_CONTAINER}

# 4. Install Nix AS the user (writes into /home/$USERNAME_CONTAINER/.nix-profile)
RUN curl -L https://nixos.org/nix/install | sh -s -- --no-daemon --yes

ENV PATH="/home/${USERNAME_CONTAINER}/.nix-profile/bin:${PATH}"

# 5. Copy shell.nix with correct ownership and install packages as the user
COPY --chown=${USERNAME_CONTAINER}:${USERNAME_CONTAINER} shell.nix /home/${USERNAME_CONTAINER}/shell.nix
RUN . /home/${USERNAME_CONTAINER}/.nix-profile/etc/profile.d/nix.sh && \
    nix-env -if /home/${USERNAME_CONTAINER}/shell.nix --extra-experimental-features nix-command

# 6. Clone config repo
RUN git clone https://github.com/hgoumner/config_repo.git /home/${USERNAME_CONTAINER}/config_repo
RUN cd /home/${USERNAME_CONTAINER}/config_repo/ && stow zsh git fzf lla lsd starship lazynvim bottom television yazi
RUN . /home/${USERNAME_CONTAINER}/.zshenv

CMD ["/bin/zsh"]
