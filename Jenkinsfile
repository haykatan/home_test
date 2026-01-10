pipeline {
  agent {
    kubernetes {
      defaultContainer 'build'
      yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
    - name: docker
      image: docker:26-dind
      securityContext:
        privileged: true
      env:
        - name: DOCKER_TLS_CERTDIR
          value: ""
      command:
        - dockerd
      args:
        - --host=tcp://0.0.0.0:2375
        - --host=unix:///var/run/docker.sock
"""
    }
  }

  environment {
    DOCKER_HOST = "tcp://localhost:2375"
  }

  stages {

    stage('Clone curl') {
      steps {
        container('docker') {
          sh 'git clone https://github.com/curl/curl.git'
        }
      }
    }

    stage('Docker Build (from repo Dockerfile)') {
      steps {
        container('docker') {
          sh '''
            until docker info >/dev/null 2>&1; do
              echo "Waiting for Docker daemon..."
              sleep 2
            done
            cd curl
            docker version
            docker build -t curl-ci:latest .
          '''
        }
      }
    }

stage('Build & Test INSIDE Docker') {
  steps {
    container('docker') {
      sh '''
        until docker info >/dev/null 2>&1; do
          echo "Waiting for Docker daemon..."
          sleep 2
        done

        docker run --rm \
          -u 0:0 \
          -v "${WORKSPACE}/curl:/usr/src" \
          -w /usr/src \
          curl-ci:latest \
          bash -eux -c "
            apt-get update &&
            apt-get install -y --no-install-recommends \
              autoconf \
              automake \
              libtool \
              pkg-config \
              libssl-dev \
              libpsl-dev \
              ca-certificates &&

            ls -la &&
            autoreconf -fi &&
            ./configure --with-openssl &&
            make -j4 &&
            make test
          "
      '''
    }
  }
}
  }
post {
  always {
    script {
        container('docker') {
      def status = currentBuild.currentResult

      sh """
        until docker info >/dev/null 2>&1; do
            echo "Waiting for Docker daemon..."
            sleep 2
        done
        docker run --rm curlimages/curl:8.6.0 \
          curl -s -X POST http://logstash-logstash.logstash.svc.cluster.local:8080 \
          -H "Content-Type: application/json" \
          -d '{
            "job": "${env.JOB_NAME}",
            "build": ${env.BUILD_NUMBER},
            "status": "${status}",
            "node": "${env.NODE_NAME}",
            "timestamp": "'\$(date -u +%Y-%m-%dT%H:%M:%SZ)'"
          }' || true
      """
    }
    }
  }
}

}
