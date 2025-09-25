pipeline {

    agent {
        docker {
            image 'node:16'        // Use Node 16 as the build agent
            args '-u root:root'    // Run as root to avoid permission issues
        }
    }

    environment {
        // environment vaariables
        DOCKER_REGISTRY = 'chamodkw19739335'
        APP_NAME = 'aws-elastic-beanstalk-express-js-sample'
        IMAGE_TAG = "${DOCKER_REGISTRY}/${APP_NAME}:latest"
        DOCKER_HOST = 'tcp://docker:2376'
        DOCKER_TLS_VERIFY = '1'
        DOCKER_CERT_PATH = '/certs/client'
    }

     stages {

        //Install Docker CLI in Node Container
        stage('Install Docker CLI') {
            steps {
                echo 'Installing Docker CLI...'
                sh 'apt-get install -y docker.io'
            }
        }

        //Install node dependencies to prior to build
        stage('Install Dependencies') {
            steps {
                echo 'Installing Node.js dependencies...'
                sh 'npm install --save'
            }
        }

        //Run unit tests
        stage('Run Unit Tests') {
            steps {
                echo 'Running unit tests...'
                sh 'npm test'
            }
        }

        //Run security scan of the dependencies vulns
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
            steps {
                echo 'Building Docker image...'
                sh "docker build -t ${IMAGE_TAG} ."
            }
        }

        //Push docker image to dockerhub
        stage('Push Docker Image') {
            steps {
                echo 'Pushing Docker image to registry...'
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds',
                                                 usernameVariable: 'DOCKER_USER',
                                                 passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin'
                    sh "docker push ${IMAGE_TAG}"
                }
            }
        }
    }  
}