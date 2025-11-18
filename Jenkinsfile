pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                script {
                    // Docker 이미지 빌드
                    sh 'docker build -t myapp:latest .'
                }
            }
        }
        stage('Test') {
            steps {
                script {
                    // 테스트 실행 (예: pytest)
                    sh 'pytest'
                }
            }
        }
        stage('Push') {
            steps {
                script {
                    // Docker Hub에 이미지 푸시
                    sh 'docker push myapp:latest'
                }
            }
        }
    }
}
