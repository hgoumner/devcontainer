FROM debian:bookworm-slim

ARG USERNAME=hristo_dev
ARG USER_UID=1000

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl xz-utils ca-certificates zsh sudo \
    && rm -rf /var/lib/apt/lists/*

# 1. Create the user FIRST
RUN useradd -m -u ${USER_UID} -s /bin/zsh ${USERNAME} \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# 2. Prep /nix with correct ownership so the user can install into it
#    (single-user Nix installs need /nix owned by the installing user)
RUN groupadd -r nixbld \
    && mkdir -m 0755 /nix \
    && chown ${USERNAME} /nix

# 3. Switch to the user for the rest of the Nix setup
USER ${USERNAME}
WORKDIR /home/${USERNAME}

# 4. Install Nix AS the user (writes into /home/$USERNAME/.nix-profile)
RUN curl -L https://nixos.org/nix/install | sh -s -- --no-daemon --yes

ENV PATH="/home/${USERNAME}/.nix-profile/bin:${PATH}"

# 5. Copy shell.nix with correct ownership and install packages as the user
COPY --chown=${USERNAME}:${USERNAME} shell.nix /home/${USERNAME}/shell.nix
RUN . /home/${USERNAME}/.nix-profile/etc/profile.d/nix.sh && \
    nix-env -if /home/${USERNAME}/shell.nix --extra-experimental-features nix-command

# 6. Clone config repo
RUN git clone https://github.com/hgoumner/config_repo.git /home/${USERNAME}/config_repo
RUN cd /home/${USERNAME}/config_repo/ && stow zsh
RUN cd /home/${USERNAME}/config_repo/ && stow starship
RUN . /home/${USERNAME}/.zshenv
#RUN . /home/${USERNAME}/.config/zsh/.zshrc

CMD ["/bin/zsh"]
