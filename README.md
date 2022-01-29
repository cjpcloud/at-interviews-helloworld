# Hello World Sample App
## Manual Build/Deploy Steps
### Build

Confirm all your desired changes are committed to the repo and pushed, then:
```
$ export COMMIT_ID=$(git rev-parse --verify --short HEAD)

$ aws-vault exec alltrails --duration=36h # or however you auth to the AWS API

$ aws ecr get-login-password \
    --region us-west-2 \
    | docker login \
    --username AWS \
    --password-stdin \
    310228935478.dkr.ecr.us-west-2.amazonaws.com

$ docker build \
    --no-cache \
    --build-arg GIT_COMMIT=$COMMIT_ID \
    -t helloworld:$COMMIT_ID \
    -t 310228935478.dkr.ecr.us-west-2.amazonaws.com/helloworld:$COMMIT_ID \
    .

$ docker push \
    310228935478.dkr.ecr.us-west-2.amazonaws.com/helloworld:$COMMIT_ID

$ unset COMMIT_ID # Skip this if you're going immediately to 'Deploy' below
```

### Deploy
```
$ kubens <your-name>

$ helm upgrade helloworld --set image.tag=$COMMIT_ID helm/helloworld
```

