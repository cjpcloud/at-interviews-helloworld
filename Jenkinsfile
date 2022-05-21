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
    


            
	
	

