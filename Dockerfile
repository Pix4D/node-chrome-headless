# FORKED FROM pastelsky/node-chrome-headless
FROM buildpack-deps:jessie
# FROM debian:stable-slim
# FROM ubuntu:xenial
# FROM google/debian:jessie

LABEL name="node-chrome-headless" \
  maintainer="Olivier Amblet <olivier.amblet@pix4d.com>" \
  version="1.0" \
  description="Node and Google Chrome Headless are in a container..."

RUN apt-get update -qqy \
  && apt-get -qqy install \
  wget ca-certificates apt-transport-https \
  jq \
  ttf-wqy-zenhei ttf-unfonts-core \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

RUN groupadd --gid 1000 node \
  && useradd --uid 1000 --gid node --shell /bin/bash --create-home node

ENV NPM_CONFIG_LOGLEVEL info
# using current Node version

ENV NODE_VERSION 12

RUN curl -sL https://deb.nodesource.com/setup_$NODE_VERSION.x | bash -
RUN apt-get install -y nodejs

RUN node --version

ENV YARN_VERSION 1.16.0
RUN curl -o- -L https://yarnpkg.com/install.sh | bash -s -- --version $YARN_VERSION


RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && echo "deb https://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
  && apt-get update -qqy \
  && apt-get -qqy install google-chrome-unstable \
  && rm /etc/apt/sources.list.d/google-chrome.list \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

RUN useradd headless --shell /bin/bash --create-home \
  && usermod -a -G sudo headless \
  && echo 'ALL ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers \
  && echo 'headless:nopassword' | chpasswd

RUN mkdir /data

# Expose Chrome Debugger port
EXPOSE 9222

ENTRYPOINT ["/usr/bin/google-chrome-unstable", \
  "--disable-gpu", \
  "--headless", \
  "--no-sandbox", \
  "--remote-debugging-address=0.0.0.0", \
  "--remote-debugging-port=9222", \
  "--user-data-dir=/data"]
