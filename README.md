### Prod Deployemnt #########

I have Created two branches dev and master(prod).By Using Jenkinsfile we a implemented the Automation through Jenkinsjob.Inside Jenkinsfile i have defined   Stages like checkout,build & deployment and postaction.When ever Engineer Commits his code in dev branch the jenkin job will get triggered by fetching the latest changes from the github,build stage will take care of building the docker image and pushing the image to ecr repo(Hello world),Once the image is pushed to ecr,then the latest image tag(Commit id) will be deployed to dev environment(dev namespace).Once image deployed to dev namespace Manager/Engineering lead will get the email notification  to promote the changes to Prod Environemnt(Based on QA Team Signoff) we can make the decision to promote the changes or not.

So if QA team sign off and everything looks good and Once the Release Mangager/DevOps Lead Approves the Request the changes will get promoted to production enviornment.
When the changes promoted to prod envionment the Release Mangager/DevOps Lead will receive email notification about deployment status.
Note:If the request isn't approved the changes will not get promoted to the production environment.

Below is the jenkins file



pipeline { 
    agent any 
    stages {
        stage ('checkout') {
             steps {
                 git branch: 'master', url: 'https://github.com/cjpcloud/at-interviews-helloworld.git'
             }
        }
		
		stage ('Deploy To Prod') {
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
    


            
	
