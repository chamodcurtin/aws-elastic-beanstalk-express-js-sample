pipeline {

    agent {
        docker {
            image 'node:16'        
            args '-u root:root'
        }
    }

    environment {
        DOCKER_REGISTRY = 'chamodkw19739335'
        APP_NAME = 'aws-elastic-beanstalk-express-js-sample'
        IMAGE_TAG = "${DOCKER_REGISTRY}/${APP_NAME}:latest"
        DOCKER_HOST = 'tcp://docker:2376'
        DOCKER_TLS_VERIFY = '1'
        DOCKER_CERT_PATH = '/certs/client'
    }

     stages {
        stage('Install Dependencies') {
            steps {
                echo 'Installing Node.js dependencies...'
                sh 'npm install --save'
            }
        }


        stage('Run Unit Tests') {
            steps {
                echo 'Running unit tests...'
                sh 'npm test'
            }
        }

        stage('Security Scan') {
            steps {
                echo 'Scanning dependencies for vulnerabilities with Snyk...'
                withCredentials([string(credentialsId: 'snyk-token', variable: 'SNYK_TOKEN')]) {
                    sh 'npm install -g snyk'
                    sh 'snyk auth $SNYK_TOKEN'
                    sh 'snyk test --severity-threshold=high'
                }
            }
        }

        //Build docker image
        stage('Build Docker Image') {
            agent any
            steps {
                echo 'Building Docker image...'
                sh "docker build -t ${IMAGE_TAG} ."
            }
        }

        //Push docker image to dockerhub
        stage('Push Docker Image') {
            agent any
            steps {
                echo 'Pushing Docker image to registry...'
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds',usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin'
                    sh "docker push ${IMAGE_TAG}"
                }
            }
        }
    }  
}