# Hello World Sample App
Welcome!  If you're cloning this repo, in all likelihood you are starting the QA/Build/Release Engineer Homework assignment.  We're so happy that you've made it this far in the process!  By now you should have received a message from HR with login credentials to our Candidate AWS Environment, and the specifics of the Homework Assignment.  The document you're reading now (this README) is intended to help get you into the AWS environment, and that your account has all the permissions it needs to test locally, and actually complete the assignment.  

# Recommended Tooling (for local deployment/testing)
We recommend having the following tools to hand: 

[Docker](https://www.docker.com/products/docker-desktop)

[AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

[Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-macos/#install-with-homebrew-on-macos)

[Helm](https://helm.sh)

# AWS Console Access
You should have received a username and (temporary) password from HR.  With that, you can log into the [AWS Console](at-interviews.signin.aws.amazon.com/) and take a look around, if you are so inclined.  

# AWS API Access
Presuming you're on a Linux or MacOS machine, you can create/edit the file `~/.aws/credentials`.  Add a new section similar to the following, substituting the example values for the ones shared by HR: 
```
[at-interviews]
aws_access_key_id =  AKIA....
aws_secret_access_key = IKGkr....
```

To verify, you should now be able to run the command:
```
$ aws --profile at-interviews \
    sts get-caller-identity
```
This should output something similar to: 
```
{
    "UserId": "AKIA....",
    "Account": "310228935478",
    "Arn": "arn:aws:iam::310228935478:user/your_user_name_here"
}
```

# Manual Build/Deploy Steps
Our toy application is already able to be built, pushed, and deployed locally. We've got the particulars crammed into the `local-deploy.sh` script, but if you'd prefer a longer-form rundown of what's going on where, read on! 

## Build

Confirm all desired changes to the toy application are committed locally (not necessarily pushed), and then:
```
$ export COMMIT_ID=$(git rev-parse --verify --short HEAD) # This gives us a short, unique tag that we'll use when building/tagging the Docker image

```
```
$ docker build \
    --no-cache \
    --build-arg GIT_COMMIT=$COMMIT_ID \
    -t helloworld:$COMMIT_ID \
    -t 310228935478.dkr.ecr.us-west-2.amazonaws.com/helloworld:$COMMIT_ID \
    .
```

We should now have a local container built and able to be run locally 'in the usual fashion'.

## Login to external services
We'll need to authenticate to some of the external services in order to send our container on its merry way: 

Elastic Container Repository
```
$ aws ecr get-login-password \
    --region us-west-2 \
    | docker login \
    --username AWS \
    --password-stdin \
    310228935478.dkr.ecr.us-west-2.amazonaws.com
```

Elastic Kubernetes Service
```
aws eks update-kubeconfig \
    --region us-west-2 \
    --name at-interviews-cluster
```

# Push
```
$ docker push \
    310228935478.dkr.ecr.us-west-2.amazonaws.com/helloworld:$COMMIT_ID
```
Using the credentials above, this sends our container to ECR where Kubernetes can pull it down and actually deploy it in the next step.  

# Deploy
We're using Helm to abstract away as much of the complexity of Kubernetes as we possibly can.  Presuming our container is safely in ECR (above), deployment to Kubernetes and all the associated wiring should be as simple as: 
```
helm upgrade \
    --install \
    --namespace $(whoami) \
    --create-namespace \
    helloworld \
    --set image.tag=$COMMIT_ID \
    helm/helloworld
```
That should plug n' chug for a minute, then spit out some `kubectl` commands that will have an Internet Accessible URL™ serving up the toy application (it may take up to 5 minutes for DNS to propagate, FWIW).  And that is the manual deploy process, annotated.  You shouldn't need to run everything command-by-command, as that's what the `local-deploy.sh` script is for, but hopefully that gives you some context helpful to completing the homework assignment.  

#Automation Build And Deploy:
         By Using Jenkinsfile we are implimented the Automation through  Jenkinsjob.Inside of Jenkinsfile we are adding some kind of Stages like checkout,build & deployment and postaction.whenever dev branch changes done at that time dev job will triger.Once triger the Job, it will fetch the latest code from github then build the dockerfile as a image(Build,Login to ECR,Image push to ECR, Deploy to EKS).Once image Build & deploy to EKS cluster then admin get the email notification.everything perfect like perfomance/scalability wise then he will accept the mail.whenever admin accept the mail at that time next job will triger then   deploy To production environment.
  
Note: He was not accept the mail at the time job will failed


branchName = "prod"
qaEmailId ="vijarram.reddy@gmail.com"
repositoryName = "demo"
waitingTime = 25
pipeline {
    agent any
    stages {
        stage ('checkout') {
             steps {
                 git branch: 'dev', url: 'https://github.com/cjpcloud/at-interviews-helloworld.git'
             }
        }

                stage ('Deploy To Dev') {
          steps {
sh './local-deploy.sh'        }

        post
    {
         success
        {
            script
            {

                    mail to: 'vijarram.reddy@gmail.com',
                     subject: "Build + Condition Pass",
                     body: "Build got success check status @ ${env.BUILD_URL}"

            }
        }

          failure
           {
                   script
                   {
                mail to: 'vijarram.reddy@gmail.com',
                     subject: "Build fail + Condition Pass",
                     body: "Build got success check status @ ${env.BUILD_URL}"


            }
        }
    }

        }


}
}

              if (branchName == "prod") {
              promoteStage()
              }

         def promoteStage(){
              // Stage: promote
                   stage ('Appprove to proceed'){
                       notifyQA()
                       proceedConfirmation("proceed1","promote to Prod ?")
                  }
                        node{
                   stage ('Promote artifacts to Prod'){
                                        echo 'Hi Cloudjournee'

                   }
                    }
                }

                def notifyQA(String buildStatus = 'STARTED') {
                // build status of null means successful
                buildStatus =  buildStatus ?: 'SUCCESSFUL'
                def toList = qaEmailId
                def subject = "QA: '${repositoryName}' artifact ready for promotion to Prod"
                def summary = "${subject} (${env.BUILD_URL})"
                def details = """
                <p>Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' is ready to be promoted from DEV to QA.</p>
                <p>Click here to move the library into the QA artifactory for testing. "<a href="${env.BUILD_URL}/input">${env.JOB_NAME}[${env.BUILD_NUMBER}]/</a>"</p>
           """
                emailext body: details,mimeType: 'text/html', subject: subject, to: toList
                }
                def proceedConfirmation(String id, String message) {
                def userInput = true
                def didTimeout = false
                try {
                timeout(time: waitingTime, unit: 'HOURS') { //
                userInput = input(
                id: "${id}", message: "${message}", parameters: [
                [$class: 'BooleanParameterDefinition', defaultValue: true, description: '', name: 'Confirm to proceed !']
             ])
          }
      }
                catch(e) { // timeout reached or input false
                def user = e.getCauses()[0].getUser()
                if('SYSTEM' == user.toString()) { // SYSTEM means timeout.
                didTimeout = true
                if (didTimeout) {
                echo "no input was received abefore timeout"
                currentBuild.result = "FAILURE"
                throw e
            }
                else if (userInput == true) {
                echo "this was successful"
            }
                else {
                userInput = false
                echo "this was not successful"
                currentBuild.result = "FAILURE"
                println("catch exeption. currentBuild.result: ${currentBuild.result}")
                throw e
            }
       }
                else {
                userInput = false
                echo "Aborted by: [${user}]"
     }
   }
 }
