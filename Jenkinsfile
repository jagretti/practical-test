pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'jagretti/webapp'
        K8S_DEPLOYMENT = 'webapp-deployment'
        K8S_NAMESPACE = 'webapp-namespace'
        DOCKER_USERNAME = 'jagretti'
        DOCKER_PASSWORD = credentials('secret-docker-password')
    }
    
    stages {
        stage('Build') {
            steps {
                script {
                    sh "docker compose -f docker-compose.yml -f docker-compose.ci.yml build"
                }
            }
        }
        
        stage('Test') {
            steps {
                script {
                    sh 'docker compose -f docker-compose.yml -f docker-compose.ci.yml run web python manage.py test'
                }
            }
        }
        
        stage('Push Image') {
            steps {
                script {
                    sh "echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin"
                    sh "docker push ${DOCKER_IMAGE}:${BUILD_ID}"
                }
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    // Assuming we just want to deploy to production
                    if (env.BRANCH_NAME == "main") {
                        sh "cd kubernetes/base && kustomize edit set image ${DOCKER_IMAGE}:${BUILD_ID}"
                        sh "kubectl apply -k kubernetes/overlays/production -n $K8S_NAMESPACE"
                    }
                }
            }
            post {
                success {
                    echo "Deployment to Kubernetes was successful"
                }
                failure {
                    echo "Deployment failed"
                }
            }
        }
    }
    
    post {
        success {
            echo "Build was succesful"
        }
        failure {
            echo "Build failed"
        }
    }
}
