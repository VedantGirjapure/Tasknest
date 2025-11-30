pipeline {
    agent any
    
    environment {
        // Nexus Configuration
        NEXUS_URL = 'http://nexus.imcc.com'
        NEXUS_USER = 'student'
        NEXUS_PASS = credentials('nexus-password') // Store in Jenkins credentials
        
        // SonarQube Configuration
        SONAR_URL = 'http://sonarqube.imcc.com'
        SONAR_TOKEN = credentials('sonar-token') // Store in Jenkins credentials
        
        // Docker Configuration
        DOCKER_REGISTRY = 'nexus.imcc.com:8082' // Nexus Docker registry port
        IMAGE_NAME = 'jira-clone'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        
        // Application Configuration
        APP_NAME = 'jira-clone'
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo '📦 Checking out code...'
                checkout scm
            }
        }
        
        stage('Install Dependencies') {
            steps {
                echo '📥 Installing dependencies...'
                sh '''
                    npm ci
                '''
            }
        }
        
        stage('SonarQube Analysis') {
            steps {
                echo '🔍 Running SonarQube analysis...'
                script {
                    def scannerHome = tool 'SonarQube Scanner' // Configure in Jenkins Global Tools
                    withSonarQubeEnv('SonarQube') { // Configure in Jenkins System Configuration
                        sh """
                            ${scannerHome}/bin/sonar-scanner \
                                -Dsonar.projectKey=jira-clone \
                                -Dsonar.sources=. \
                                -Dsonar.host.url=${SONAR_URL} \
                                -Dsonar.login=${SONAR_TOKEN} \
                                -Dsonar.exclusions=**/node_modules/**,**/.next/**,**/coverage/**,**/*.test.js
                        """
                    }
                }
            }
        }
        
        stage('Quality Gate') {
            steps {
                echo '✅ Checking SonarQube Quality Gate...'
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
        
        stage('Generate Prisma Client') {
            steps {
                echo '🔧 Generating Prisma Client...'
                sh '''
                    npx prisma generate
                '''
            }
        }
        
        stage('Build Application') {
            steps {
                echo '🏗️ Building Next.js application...'
                sh '''
                    npm run build
                '''
            }
        }
        
        stage('Build and Push Docker Image') {
            steps {
                echo '🐳 Building Docker image...'
                script {
                    // Login to Nexus Docker registry
                    sh """
                        docker login ${DOCKER_REGISTRY} -u ${NEXUS_USER} -p ${NEXUS_PASS}
                    """
                    
                    // Build Docker image
                    def dockerImage = docker.build("${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}")
                    
                    // Push to Nexus
                    echo '📤 Pushing Docker image to Nexus...'
                    dockerImage.push()
                    dockerImage.push("${DOCKER_REGISTRY}/${IMAGE_NAME}:latest")
                }
            }
        }
        
        stage('Deploy to Server') {
            steps {
                echo '🚀 Deploying to server...'
                script {
                    // SSH into server and deploy
                    sshagent(['server-ssh-key']) {
                        sh '''
                            ssh -o StrictHostKeyChecking=no student@your-server-ip << 'EOF'
                                cd /var/www/jira-clone
                                
                                # Pull latest image from Nexus
                                docker login nexus.imcc.com:8082 -u student -p ${NEXUS_PASS}
                                docker pull ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}
                                
                                # Stop and remove old container
                                docker stop ${APP_NAME} || true
                                docker rm ${APP_NAME} || true
                                
                                # Run new container
                                docker run -d \\
                                    --name ${APP_NAME} \\
                                    --restart unless-stopped \\
                                    -p 3000:3000 \\
                                    --env-file .env \\
                                    ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}
                                
                                # Clean up old images
                                docker image prune -f
                            EOF
                        '''
                    }
                }
            }
        }
    }
    
    post {
        success {
            echo '✅ Pipeline completed successfully!'
            // Optional: Send notification
        }
        failure {
            echo '❌ Pipeline failed!'
            // Optional: Send notification
        }
        always {
            echo '🧹 Cleaning up...'
            sh 'docker system prune -f || true'
        }
    }
}

