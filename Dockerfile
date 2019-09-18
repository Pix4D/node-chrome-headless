# FORKED FROM pastelsky/node-chrome-headless
FROM buildpack-deps:buster
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

# gpg keys listed at https://github.com/nodejs/node
RUN set -ex \
  && for key in \
  94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
  FD3A5288F042B6850C66B31F09FE44734EB7990E \
  71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
  DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
  C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
  B9AE9905FFD7803F25714661B63B535A4C206CA9 \
  56730D5401028683275BD23C23EFEFE93C4CFFFE \
  77984A986EBC2AA786BC0F66B01FBB92821C587A \
  ; do \
  gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
  done

ENV NPM_CONFIG_LOGLEVEL info
# using current Node version
ENV NODE_VERSION 12

RUN curl -sL https://deb.nodesource.com/setup_$NODE_VERSION.x | bash -

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update && apt-get install -y nodejs yarn

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
