#!/bin/bash
set -eo pipefail

export COMMIT_ID=$(git rev-parse --verify --short HEAD)
echo commit ID is $COMMIT_ID

aws ecr get-login-password \
    --region us-west-2 \
    | docker login \
    --username AWS \
    --password-stdin \
    310228935478.dkr.ecr.us-west-2.amazonaws.com

docker build \
    --no-cache \
    --build-arg GIT_COMMIT=$COMMIT_ID \
    -t helloworld:$COMMIT_ID \
    -t 310228935478.dkr.ecr.us-west-2.amazonaws.com/helloworld:$COMMIT_ID \
    .

docker push \
    310228935478.dkr.ecr.us-west-2.amazonaws.com/helloworld:$COMMIT_ID

kubectx prod
kubens production


helm upgrade helloworld --set image.tag=$COMMIT_ID helm/helloworld
echo Deployed commit $COMMIT_ID
unset COMMIT_ID
