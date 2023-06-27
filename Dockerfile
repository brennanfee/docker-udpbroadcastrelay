# vim: set ft=dockerfile :
ARG edition=12
FROM debian:${edition} AS base

# Update and install any packages needed for build phase
RUN apt-get update \
  && apt-get upgrade -y \
  && apt-get autoremove -y \
  && apt-get install -y --no-install-recommends build-essential git ca-certificates \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/src

# Pull and compile the tool, copy it to /srv
RUN git clone --depth 1 https://github.com/marjohn56/udpbroadcastrelay.git .\
  && make \
  && cp udpbroadcastrelay /srv/udpbroadcastrelay

# Copy the current directory contents into the container at /srv
COPY start.bash /srv/start.bash

# Build the final image
FROM debian:${edition}
COPY --from=base /srv /srv

# yq is needed by the script
RUN apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y --no-install-recommends yq iproute2 \
  && apt-get autoremove -y \
  && rm -rf /var/lib/apt/lists/*

LABEL author="Brennan A. Fee"
LABEL documentation=https://github.com/brennanfee/docker-udpbroadcastrelay
LABEL version=1.0.0
LABEL license=MIT

# Define environment variable
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV LANG C.UTF-8
ENV TZ America/Chicago

# Run when the container launches
CMD ["/usr/bin/bash", "/srv/start.bash"]
