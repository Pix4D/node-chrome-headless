docker --version
docker images
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
docker tag node-chrome-headless $DOCKER_TEAM/node-chrome-headless
docker push $DOCKER_TEAM/node-chrome-headless
