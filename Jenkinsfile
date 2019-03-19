#!groovy

pipeline {
  agent none

  environment {
    STAGING_INSTANCE_ID = 'i-01f2884b0040c8809'
  }

  options {
    disableConcurrentBuilds()
  }

  stages {
    stage('Build Docker image') {
      agent any
      steps {
        script {
          def dockerRepoName = 'zooniverse/caesar'
          def dockerImageName = "${dockerRepoName}:${BRANCH_NAME}"
          def newImage = docker.build(dockerImageName)
          newImage.push()

          if (BRANCH_NAME == 'master') {
            stage('Update latest tag') {
              newImage.push('latest')
            }
          }
        }
      }
    }

    stage('Update staging containers') {
      when { branch 'master' }
      failFast true
      options {
        skipDefaultCheckout true
      }
      agent {
        docker {
          image 'zooniverse/operations:latest'
          args '-v "$HOME/.ssh/:/home/ubuntu/.ssh" -v "$HOME/.aws/:/home/ubuntu/.aws"'
        }
      }
      steps {
        sh """#!/bin/bash -e
          while true; do sleep 3; echo -n "."; done &
          KEEP_ALIVE_ECHO_JOB=\$!
          cd /operations
          ./update_in_place.sh -i $STAGING_INSTANCE_ID panoptes-redis-staging caesar
          kill \${KEEP_ALIVE_ECHO_JOB}
        """
      }
    }

    //stage('Update production containers') {
      //when { tag 'production' }
      //failFast true
      //options {
        //skipDefaultCheckout true
      //}
      //agent {
        //docker {
          //image 'zooniverse/operations:latest'
          //args '-v "$HOME/.ssh/:/home/ubuntu/.ssh" -v "$HOME/.aws/:/home/ubuntu/.aws"'
        //}
      //}
      //steps {
        //sh """#!/bin/bash -e
          //while true; do sleep 3; echo -n "."; done &
          //KEEP_ALIVE_ECHO_JOB=\$!
          //cd /operations
          //./update_in_place.sh -i $STAGING_AMI_ID panoptes-redis-staging caesar
          //kill \${KEEP_ALIVE_ECHO_JOB}
        //"""
      //}
    //}
  }
}
