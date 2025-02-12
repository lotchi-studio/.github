pipeline {
  agent {
    docker {
      image 'python:3.11'
    }
  }
  parameters {
    string(name: 'ADDITIONAL_STEPS', defaultValue: '', description: 'Additional steps to run')
  }
  stages {
    stage('Set up Python') {
      steps {
        sh "python -m pip install --upgrade pip"
        sh "pip install black"
      }
    }
    stage('Check code formatting') {
      steps {
        sh "black --check ."
      }
    }
    stage('Run additional steps') {
      when {
        expression { return params.ADDITIONAL_STEPS != '' }
      }
      steps {
        sh "${params.ADDITIONAL_STEPS}"
      }
    }
  }
}