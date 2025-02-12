pipeline {
    agent any
    stages {
        stage('Install Python (Attempt)') {
            steps {
                sh 'curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh'
                sh 'bash Miniconda3-latest-Linux-x86_64.sh -b -p $HOME/miniconda'
                sh '$HOME/miniconda/bin/python -m pip install --upgrade pip'
                sh '$HOME/miniconda/bin/pip install black'
            }
        }
        stage('Check code formatting') {
            steps {
                sh '$HOME/miniconda/bin/black --check .'
            }
        }
    }
}
