pipeline {
  agent {
    kubernetes {
      defaultContainer 'docker'
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
        - name: HARBOR_PASSWORD
          valueFrom:
            secretKeyRef:
              name: harbor-core
              key: HARBOR_ADMIN_PASSWORD
      command:
        - dockerd
      args:
        - --insecure-registry=harbor.jenkins.svc.cluster.local
        - --host=tcp://0.0.0.0:2375
        - --host=unix:///var/run/docker.sock

    - name: curl
      image: curlimages/curl:8.6.0
      command:
        - sh
        - -c
        - sleep infinity

"""
    }
  }

  environment {
    DOCKER_HOST = "tcp://localhost:2375"
    REGISTRY    = "harbor.jenkins.svc.cluster.local"
    PROJECT     = "library"
    IMAGE       = "curl-ci"
    TAG         = "${BUILD_NUMBER}"
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
            docker build -t ${IMAGE}:latest .
          '''
        }
      }
    }

    stage('Build & Test INSIDE Docker') {
      steps {
        container('docker') {
          sh '''
            until docker info >/dev/null 2>&1; do
              sleep 2
            done

            docker run --rm \
              -u 0:0 \
              -v "${WORKSPACE}/curl:/usr/src" \
              -w /usr/src \
              ${IMAGE}:latest \
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

                autoreconf -fi &&
                ./configure --with-openssl &&
                make -j4 &&
                make test TFLAGS=~1510,~1511
              "
          '''
        }
      }
    }

    stage('Push image to Harbor') {
      steps {
        container('docker') {
          sh '''
            until docker info >/dev/null 2>&1; do
              sleep 2
            done

            echo "$HARBOR_PASSWORD" | docker login $REGISTRY \
              -u admin \
              --password-stdin

            docker tag ${IMAGE}:latest \
              $REGISTRY/$PROJECT/$IMAGE:$TAG

            docker push \
              $REGISTRY/$PROJECT/$IMAGE:$TAG
          '''
        }
      }
    }
  


}


post {
  always {
    script {
      def status = currentBuild.currentResult

      def payload = [
        job       : env.JOB_NAME,
        build     : env.BUILD_NUMBER as Integer,
        status    : status,
        node      : env.NODE_NAME,
        timestamp : new Date().format("yyyy-MM-dd'T'HH:mm:ss'Z'", TimeZone.getTimeZone("UTC"))
      ]

      httpRequest(
        httpMode: 'POST',
        url: 'http://logstash-logstash.logstash.svc.cluster.local:8080',
        contentType: 'APPLICATION_JSON',
        requestBody: groovy.json.JsonOutput.toJson(payload),
        validResponseCodes: '100:599' // שלא יפיל את הבילד
      )
    }
  }
}

}
