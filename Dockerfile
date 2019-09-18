# FORKED FROM pastelsky/node-chrome-headless
FROM buildpack-deps:buster
# FROM debian:stable-slim
# FROM ubuntu:xenial
# FROM google/debian:jessie

LABEL name="node-chrome-headless" \
  maintainer="Olivier Amblet <olivier.amblet@pix4d.com>" \
  version="1.0" \
  description="Node and Google Chrome Headless are in a container..."

RUN groupadd --gid 1000 node \
  && useradd --uid 1000 --gid node --shell /bin/bash --create-home node

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update && apt-get install -y nodejs yarn

RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update && apt-get install -y google-chrome-stable

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
