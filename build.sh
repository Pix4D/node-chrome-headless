#!/bin/bash
docker --version
docker build --no-cache -t node-chrome-headless -f Dockerfile context
docker images