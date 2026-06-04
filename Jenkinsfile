pipeline {
    agent any

    stages {

        stage('Clone Code') {
            steps {
                git 'https://github.com/ashi-oss/quizmaster.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                bat 'docker build -t quizmaster-app .'
            }
        }

        stage('Stop Old Container') {
            steps {
                bat 'docker stop quizmaster-container || exit 0'
                bat 'docker rm quizmaster-container || exit 0'
            }
        }

        stage('Run New Container') {
            steps {
                bat 'docker run -d -p 5000:5000 --name quizmaster-container quizmaster-app'
            }
        }
    }
}