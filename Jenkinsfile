pipeline {
    agent any
    stages {
        stage('Install Python') {
            steps {
                sh '''
                if [ -d "$HOME/miniconda" ]; then
                echo "Miniconda already exists. Removing..."
                rm -rf "$HOME/miniconda"
                fi
                curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
                bash Miniconda3-latest-Linux-x86_64.sh -b -p "$HOME/miniconda"
                $HOME/miniconda/bin/python -m pip install --upgrade pip
                $HOME/miniconda/bin/pip install black
                '''
            }
        }
        stage('Check code formatting') {
            steps {
                sh '$HOME/miniconda/bin/black --check .'
            }
        }
    }
}
