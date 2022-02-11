#!/bin/bash
set -eo pipefail

# You can pick a unique single-word namespace by passing it as an argument
# to this script, or it'll try to make one for you from your 
# machine's username

AWS_ACCOUNT="310228935478"

# This confirms we're pointing at the appropriate AWS account
CURRENT_AWS_TARGET=$(aws sts get-caller-identity \
    | grep Account \
    | awk -F: '{print $2}' \
    | tr -d \"\,\ \
    )

if [[ ! "$CURRENT_AWS_TARGET" = "$AWS_ACCOUNT" ]]; then
    echo "We don't appear to be authenticating to the Alltrails AWS account"
    echo "Please double-check your AWS access key and try again"
    echo
    echo "Expected AWS account number of $AWS_ACCOUNT, got $CURRENT_AWS_TARGET instead" 
    exit 1
fi

# Let's try to set a unique-ish namespace for local testing
if [ $# -eq 0 ]; then
    NAMESPACE=$(whoami)
else
    NAMESPACE=$1
fi

export COMMIT_ID=$(git rev-parse --verify --short HEAD)
echo commit ID is $COMMIT_ID

aws eks update-kubeconfig \
    --region us-west-2 \
    --name at-interviews-cluster

aws ecr get-login-password \
    --region us-west-2 \
    | docker login \
    --username AWS \
    --password-stdin \
    $AWS_ACCOUNT.dkr.ecr.us-west-2.amazonaws.com

docker build \
    --no-cache \
    --build-arg GIT_COMMIT=$COMMIT_ID \
    -t helloworld:$COMMIT_ID \
    -t $AWS_ACCOUNT.dkr.ecr.us-west-2.amazonaws.com/helloworld:$COMMIT_ID \
    .

docker push \
    $AWS_ACCOUNT.dkr.ecr.us-west-2.amazonaws.com/helloworld:$COMMIT_ID


helm upgrade \
    --install \
    --namespace $NAMESPACE \
    --create-namespace \
    helloworld \
    --set image.tag=$COMMIT_ID \
    helm/helloworld

echo "Deployed commit $COMMIT_ID to namespace $NAMESPACE"
unset COMMIT_ID
