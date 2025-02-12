pipeline {
    agent any
    stages {
        stage('Install Python (Attempt)') {
            steps {
                sh 'wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh'
                sh 'bash miniconda.sh -b -p $HOME/miniconda'
                sh 'export PATH="$HOME/miniconda/bin:$PATH"'
                sh 'python -m pip install --upgrade pip'
                sh 'pip install black'
            }
        }
        stage('Check code formatting') {
            steps {
                sh 'black --check .'
            }
        }
    }
}
