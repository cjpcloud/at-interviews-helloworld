##### Dev Deployment ####

Automation of Existing Build And Deploy Process:
I have Created two branches dev and master(prod).By Using Jenkinsfile we a implemented the Automation through Jenkinsjob.Inside Jenkinsfile i have defined   Stages like checkout,build & deployment and postaction.When ever Engineer Commits his code in dev branch the jenkin job will get triggered by fetching the latest changes from the github,build stage will take care of building the docker image and pushing the image to ecr repo(Hello world),Once the image is pushed to ecr,then the latest image tag(Commit id) will be deployed to eks dev environment(dev namespace).Once image deployed to dev namespace Release Mangager/DevOps Lead lead will get the email notification to promote the changes to Prod Environemnt(Based on QA Team Signoff) we can make the decision to promote the changes or not.

Note: Whenever the Dev job get triggered the "Deploy To Dev" stage will execute the local-deploy.sh script where as image buid and ecr login,image push to ecr,helm update are taken care.

Below is the Jenkins file 

branchName = "dev"
qaEmailId ="vijarram.reddy@gmail.com"
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
              if (branchName == "dev") {
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



