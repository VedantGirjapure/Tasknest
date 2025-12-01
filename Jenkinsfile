pipeline {

    // Run the pipeline on a Kubernetes agent with 3 containers:
    // - sonar-scanner  : to run SonarQube analysis
    // - kubectl        : to deploy to Kubernetes
    // - dind (docker)  : to build and push Docker images
    agent {
        kubernetes {
            yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: sonar-scanner
    image: sonarsource/sonar-scanner-cli
    command:
      - cat
    tty: true

  - name: kubectl
    image: bitnami/kubectl:latest
    command:
      - cat
    tty: true
    securityContext:
      runAsUser: 0
      readOnlyRootFilesystem: false
    env:
    - name: KUBECONFIG
      value: /kube/config
    volumeMounts:
    - name: kubeconfig-secret
      mountPath: /kube/config
      subPath: kubeconfig

  - name: dind
    image: docker:dind
    securityContext:
      privileged: true
    env:
    - name: DOCKER_TLS_CERTDIR
      value: ""
    volumeMounts:
    - name: docker-config
      mountPath: /etc/docker/daemon.json
      subPath: daemon.json

  volumes:
  - name: docker-config
    configMap:
      name: docker-daemon-config

  - name: kubeconfig-secret
    secret:
      secretName: kubeconfig-secret
'''
        }
    }

    environment {
        // Docker / Nexus
        DOCKER_REGISTRY   = 'nexus.imcc.com'
        DOCKER_REPOSITORY = '2401056-tasknest'          // adjust to the repo your professor created
        IMAGE_NAME        = 'tasknest'
        IMAGE_TAG         = 'latest'

        // SonarQube
        SONAR_PROJECT_KEY = 'tasknest'
        // Internal Sonar URL used inside the cluster – keep as given by college
        SONAR_HOST_URL    = 'http://my-sonarqube-sonarqube.sonarqube.svc.cluster.local:9000'
    }

    stages {

        stage('Build Docker Image') {
            steps {
                container('dind') {
                    sh '''
                        # wait for docker daemon to be ready
                        sleep 15
                        docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                        docker image ls
                    '''
                }
            }
        }

        // (Optional) you can add a test stage here if you have tests to run inside the container

        stage('SonarQube Analysis') {
            steps {
                container('sonar-scanner') {
                    // Use your existing sonar token credential: sonar-token-2401056
                    withCredentials([string(credentialsId: 'sonar-token-2401056', variable: 'SONAR_TOKEN')]) {
                        sh '''
                            sonar-scanner \
                              -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                              -Dsonar.host.url=${SONAR_HOST_URL} \
                              -Dsonar.token=$SONAR_TOKEN
                        '''
                    }
                }
            }
        }

        stage('Login to Docker Registry') {
            steps {
                container('dind') {
                    // Use your existing Nexus credential: 2401056-Nexus (username + password)
                    withCredentials([usernamePassword(credentialsId: '2401056-Nexus', usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASS')]) {
                        sh '''
                            docker --version
                            sleep 10
                            docker login ${DOCKER_REGISTRY} -u $NEXUS_USER -p $NEXUS_PASS
                        '''
                    }
                }
            }
        }

        stage('Build - Tag - Push') {
            steps {
                container('dind') {
                    sh '''
                        TARGET_IMAGE=${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/${IMAGE_NAME}:${IMAGE_TAG}
                        docker tag ${IMAGE_NAME}:${IMAGE_TAG} $TARGET_IMAGE
                        docker push $TARGET_IMAGE
                        docker pull $TARGET_IMAGE
                        docker image ls
                    '''
                }
            }
        }

        stage('Deploy Tasknest Application') {
            steps {
                container('kubectl') {
                    script {
                        // assumes you have k8s-deployment/tasknest-deployment.yaml in your repo
                        dir('k8s-deployment') {
                            sh '''
                                kubectl apply -f tasknest-deployment.yaml
                                # Adjust namespace if your college uses a specific one, e.g. 2401056
                                kubectl rollout status deployment/tasknest-deployment -n 2401056
                            '''
                        }
                    }
                }
            }
        }
    }
}