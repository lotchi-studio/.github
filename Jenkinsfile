pipeline {
  agent any
  parameters {
    string(name: 'ADDITIONAL_STEPS', defaultValue: '', description: 'Additional steps to run')
  }
  stages {
    stage('Set up Python') {
      steps {
        // Use the Python plugin to run Python commands
        python {
          command "python -m pip install --upgrade pip"
        }
        python {
          command "pip install black"
        }
      }
    }
    stage('Check code formatting') {
      steps {
        python {
          command "black --check ."
        }
      }
    }
    stage('Run additional steps') {
      when {
        expression { return params.ADDITIONAL_STEPS != '' }
      }
      steps {
        python {
          command "${params.ADDITIONAL_STEPS}"
        }
      }
    }
  }
}