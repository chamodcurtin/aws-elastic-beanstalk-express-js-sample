pipeline {

    agent any

    environment {
        DOCKER_REGISTRY = 'chamodkw19739335'
        APP_NAME = 'aws-elastic-beanstalk-express-js-sample'
        IMAGE_TAG = "${DOCKER_REGISTRY}/${APP_NAME}:latest"
        DOCKER_HOST = 'tcp://docker:2376'
        DOCKER_TLS_VERIFY = '1'
        DOCKER_CERT_PATH = '/certs/client'
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10')) // Keep last 10 builds
        timestamps() // Add timestamps to console output
        ansiColor('xterm') // Colorize console output
        timeout(time: 30, unit: 'MINUTES') // Build timeout
    }
    
     stages {
        stage('Install Dependencies') {
            agent {
                docker {
                    image 'node:16'        
                    args '-u root:root'
                    reuseNode true
                }
            }
            steps {
                echo '📦 Installing Node.js dependencies...'
                sh 'npm install --save'
                echo '✅ Dependencies installed successfully'
            }
        }


        stage('Run Unit Tests') {
            agent {
                docker {
                    image 'node:16'        
                    args '-u root:root'
                    reuseNode true
                }
            }
            steps {
                echo '🧪 Running unit tests...'
                sh 'npm test'
                echo '✅ Unit tests completed'
            }
        }

        stage('Security Scan') {
            agent {
                docker {
                    image 'node:16'        
                    args '-u root:root'
                    reuseNode true
                }
            }
            steps {
                echo '🔒 Scanning for vulnerabilities with Snyk...'
                withCredentials([string(credentialsId: 'snyk-token', variable: 'SNYK_TOKEN')]) {
                    sh 'npm install -g snyk'
                    sh 'snyk auth $SNYK_TOKEN'
                    sh 'snyk test --severity-threshold=high'
                }
                echo "✅ Security scan passed - No Critical or High vulnerabilities"
            }
        }

        //Build docker image
        stage('Build Docker Image') {
            steps {
                echo '🐳 Building Docker image...'
                sh "docker build -t ${IMAGE_TAG} ."
                echo '✅ Docker image built successfully'
                // Save Docker image info for logging
                sh "docker images | grep ${APP_NAME} > docker-image-info.txt"
                archiveArtifacts artifacts: 'docker-image-info.txt', fingerprint: true
            }
        }

        //Push docker image to dockerhub
        stage('Push Docker Image') {
            steps {
                echo '📤 Pushing Docker image to registry...'
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds',usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin'
                    sh "docker push ${IMAGE_TAG}"
                }
                echo '✅ Docker image pushed successfully'
            }
        }
    }  
}