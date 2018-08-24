FROM alpine:latest
LABEL maintainer="seth@sethvargo.com"

# Install apt-utils to be helpful
RUN apk --no-cache add curl gnupg unzip

# Install the hashicorp gpg key - the key exists on keyservers, but they aren't
# reliably available. After a lot of testing, it's easier to just manage the key
# ourselves.
COPY hashicorp.asc /tmp/hashicorp.asc
COPY hashicorp.trust /tmp/hashicorp.trust
RUN \
  gpg --import /tmp/hashicorp.asc && \
  gpg --import-ownertrust /tmp/hashicorp.trust && \
  rm /tmp/hashicorp.asc && \
  rm /tmp/hashicorp.trust

# Install the helper tool
COPY install-hashicorp-tool.sh /install-hashicorp-tool
RUN chmod +x /install-hashicorp-tool

# Where the software will be
RUN mkdir -p /software

# Setup the entrypoint
ENTRYPOINT ["/install-hashicorp-tool"]
