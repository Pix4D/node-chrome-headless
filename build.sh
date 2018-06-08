#!/bin/bash
docker --version
docker build --no-cache -t pix4d/node-chrome-headless -f Dockerfile context
docker images