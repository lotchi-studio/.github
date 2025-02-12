pipeline {
  agent any
  parameters {
    string(name: 'PYTHON_VERSION', defaultValue: '3.11', description: 'Python version to use')
    string(name: 'ADDITIONAL_STEPS', defaultValue: '', description: 'Additional steps to run')
  }
  environment {
    GIT_CREDENTIALS_ID = 'github-credentials'
  }
  stages {
    stage('Checkout') {
      steps {
        script {
          checkout([$class: 'GitSCM', branches: [[name: '*/main']],
            doGenerateSubmoduleConfigurations: false,
            extensions: [],
            userRemoteConfigs: [[url: 'https://github.com/C14-studio/.github', credentialsId: env.GIT_CREDENTIALS_ID]]
          ])
        }
      }
    }
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