pipeline {
  environment {
    DOCKER_IMAGE_NAME = "sadilegend/todo-backend"
    dockerImage = ""
    DOCKERHUB_CREDENTIALS = credentials('docker-hub')
  }

  agent {
    kubernetes {
      yaml '''
      apiVersion: v1
      kind: Pod
      spec:
        serviceAccountName: jenkins-admin
        dnsConfig:
          nameserver:
            - 8.8.8.8
        containers:
        - name: docker
          image: docker:latest
          command:
          - cat
          tty: true
          volumeMounts:
            - mountPath: /var/run/docker.sock
              name: docker-sock
        - name: kubectl
          image: bitnami/kubectl:latest
          command:
          - cat
          tty: true
        securityContext:
          runAsUser: 1000
        imagePullSecrets:
          - name: regcred
        volumes:
          - name: docker-sock
            hostPath:
              path: /var/run/docker.sock
            '''
    }
  }

  stages {
    stage('Build Image') {
      steps {
        container('docker') {
          script {
            sh 'docker build --network=host -t $DOCKER_IMAGE_NAME .'
          }
        }
      }
    }

    stage('Push Image') {
      steps {
        container('docker') {
          script {
            sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login  -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
            sh 'docker tag $DOCKER_IMAGE_NAME $DOCKER_IMAGE_NAME'
            sh 'docker push $DOCKER_IMAGE_NAME:latest'
          }
        }
      }
    }

    stage('Deploying app to Kubernetes') {
      steps {
        container('kubectl') {
          script {
            withCredentials([file(credentialsId: 'config', variable: 'TMPKUBECONFIG')]) {
              sh "cat \$TMPKUBECONFIG"
              sh "cp \$TMPKUBECONFIG /.kube/config"
              sh "kubectl apply -f "
            }
          }
        }
      }
    }
  }
}
