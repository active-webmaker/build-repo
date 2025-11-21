pipeline {
    agent any

    environment {
        // Docker Hub
        DOCKER_REGISTRY_USER = 'aderbart'
        DOCKER_IMAGE_NAME    = 'django-blog-app'
        DOCKER_CREDS_ID      = 'dockerhub'

        // GitOps target repo
        DEPLOY_REPO_URL      = 'github.com/active-webmaker/deploy-repo.git'
        DEPLOY_YAML_PATH     = './django_blog_app/deployment.yaml'
        GITHUB_TOKEN_ID      = 'aws_github_token'
    }

    stages {
        stage('Checkout') {
            steps { checkout scm }
        }

        stage('Build & Push Image') {
            steps {
                script {
                    env.IMAGE_TAG = "v${env.BUILD_NUMBER}"
                    sh "docker build -t ${DOCKER_REGISTRY_USER}/${DOCKER_IMAGE_NAME}:${IMAGE_TAG} Django_Server"
                    withCredentials([usernamePassword(credentialsId: DOCKER_CREDS_ID, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                        sh "docker push ${DOCKER_REGISTRY_USER}/${DOCKER_IMAGE_NAME}:${IMAGE_TAG}"
                    }
                }
            }
        }

        stage('Update deploy-repo') {
            steps {
                script {
                    withCredentials([string(credentialsId: GITHUB_TOKEN_ID, variable: 'GITHUB_TOKEN')]) {
                        sh '''
                            set -e
                            git clone https://x-access-token:$GITHUB_TOKEN@${DEPLOY_REPO_URL} deploy-repo-temp

                            # 매니페스트 복사
                            mkdir -p deploy-repo-temp/django_blog_app
                            cp -f Django_Server/k8s/deployment.yaml deploy-repo-temp/django_blog_app/deployment.yaml
                            cp -f Django_Server/k8s/service.yaml deploy-repo-temp/django_blog_app/service.yaml

                            cd deploy-repo-temp
                            git config user.email "jenkins@pipeline.com"
                            git config user.name "Jenkins Pipeline"

                            # 이미지 태그 업데이트
                            sed -i "s|image: .*|image: ${DOCKER_REGISTRY_USER}/${DOCKER_IMAGE_NAME}:${IMAGE_TAG}|g" "$DEPLOY_YAML_PATH"

                            if [ -n "$(git status --porcelain)" ]; then
                                git add django_blog_app/deployment.yaml django_blog_app/service.yaml
                                git commit -m "Update django_blog_app image to ${IMAGE_TAG}"
                                git push origin main
                            else
                                echo "No changes to commit."
                            fi
                        '''
                    }
                }
            }
        }
    }

    post {
        always {
            sh "docker rmi ${DOCKER_REGISTRY_USER}/${DOCKER_IMAGE_NAME}:${IMAGE_TAG} || true"
            sh "rm -rf deploy-repo-temp || true"
        }
    }
}
