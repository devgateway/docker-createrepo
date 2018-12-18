#!/usr/bin/env groovy
// Copyright 2018, Development Gateway, see COPYING
pipeline {
  agent any

  environment {
    APP_NAME = 'createrepo'
    VERSION = '0.10.4'
    IMAGE = "devgateway/$APP_NAME:$VERSION"
  }

  stages {

    stage('Build') {
      steps {
        script {
          docker.build(
            env.IMAGE, ' '.join([
              "--build-arg=OPENLDAP_VERSION=$VERSION",
              '--build-arg=HTTP_PROXY=http://webcache.virtual.devgateway.org',
              '--build-arg=HTTPS_PROXY=http://webcache.virtual.devgateway.org',
              '.'
            ]))
        }
      }
    } // stage

    stage('Publish') {
      steps {
        script {
          docker.withRegistry('', 'dockerhub-ssemenukha') {
            docker.image(env.IMAGE).push()
          }
        }
      }
    } // stage

  } // stages

  post {
    success {
      script {
        def msg = sh(
          returnStdout: true,
          script: 'git log --oneline --format=%B -n 1 HEAD | head -n 1'
        )
        slackSend(
          message: "Built <$BUILD_URL|$JOB_NAME $BUILD_NUMBER>: $msg",
          color: "good"
        )
      }
    }
  }
}
