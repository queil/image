FROM ubuntu:22.04

# user setup
ARG USER=queil
ARG HOME=/home/$USER
RUN adduser $USER

# software
RUN apt-get update && apt-get install -y curl git
RUN curl -sS https://starship.rs/install.sh -o ./install.sh && \
    chmod +x ./install.sh && ./install.sh --yes && rm ./install.sh
COPY --from=docker:cli /usr/local/bin/docker /usr/local/bin/docker

# config
COPY starship.toml $HOME/.config/

# bashrc setup
RUN echo 'eval "$(starship init bash)"' >> $HOME/.bashrc

USER $USER
WORKDIR $HOME
