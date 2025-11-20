pipeline {
    agent any

    environment {
        // --- [설정 변경 구간 시작] ---
        // 1. Docker Hub 설정
        // 변경: 사용자 제공 Docker Hub 리포지토리 `aderbart/aws-cicd-repo` 사용
        DOCKER_REGISTRY_USER = 'aderbart'     // Docker Hub 사용자명 (네임스페이스)
        DOCKER_IMAGE_NAME    = 'aws-cicd-repo'        // 생성할 이미지 이름 (리포지토리명)
        
        // 2. GitOps 설정 (배포용 리포지토리)
        DEPLOY_REPO_URL      = 'github.com/active-webmaker/deploy-repo.git' // https:// 제외
        DEPLOY_YAML_PATH     = './k8s/deployment.yaml' // deploy-repo 내에서 수정할 yaml 파일 경로
        
        // 3. Jenkins에 등록한 Credential ID
        // 참고: `Credentials.md`에 등록된 이름/ID를 사용하세요.
        // 예시: Credentials.md에 따르면 Docker Hub 자격은 'dockerhub', GitHub 토큰은 'aws_github_token' 입니다.
        DOCKER_CREDS_ID      = 'dockerhub'
        GITHUB_TOKEN_ID      = 'aws_github_token'
        // --- [설정 변경 구간 끝] ---
    }

    stages {
        // 1단계: 소스 코드 체크아웃 (Jenkins가 자동으로 build-repo를 가져옴)
        stage('Checkout Source') {
            steps {
                echo 'Checking out source code...'
                checkout scm
            }
        }

        // 2단계: 애플리케이션 빌드 & 테스트 (언어에 맞게 주석 해제)
        stage('Build Application') {
            steps {
                echo 'Building application...'
                // Java (Gradle)
                // sh './gradlew clean build'
                
                // Java (Maven)
                // sh 'mvn clean package'
                
                // Node.js
                // sh 'npm install && npm run build'
            }
        }

        // 3단계: Docker 이미지 빌드
        stage('Build Docker Image') {
            steps {
                script {
                    // 빌드 번호를 태그로 사용 (예: v1, v2...)
                    env.IMAGE_TAG = "v${env.BUILD_NUMBER}"
                    echo "Building Docker Image: ${env.DOCKER_REGISTRY_USER}/${env.DOCKER_IMAGE_NAME}:${env.IMAGE_TAG}"
                    
                    // docker build 명령어 실행
                    sh "docker build -t ${env.DOCKER_REGISTRY_USER}/${env.DOCKER_IMAGE_NAME}:${env.IMAGE_TAG} ."
                }
            }
        }

        // 4단계: Docker Hub로 이미지 푸시
        stage('Push to Docker Hub') {
            steps {
                script {
                    echo 'Pushing image to Docker Hub...'
                    // Jenkins Credentials를 사용하여 로그인 후 푸시
                        withCredentials([usernamePassword(credentialsId: env.DOCKER_CREDS_ID, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        // Use single-quoted shell string to avoid Groovy interpolating $DOCKER_PASS / $DOCKER_USER
                        sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                        sh "docker push ${env.DOCKER_REGISTRY_USER}/${env.DOCKER_IMAGE_NAME}:${env.IMAGE_TAG}"
                    }
                }
            }
        }

        // 5단계: deploy-repo (Manifest) 업데이트 -> ArgoCD 감지 유발
        stage('Update Manifest Repository') {
            steps {
                script {
                    echo 'Updating Kubernetes Manifest in deploy-repo...'
                    
                    // GitHub Token을 사용하여 deploy-repo 클론 및 수정
                    withCredentials([string(credentialsId: env.GITHUB_TOKEN_ID, variable: 'GITHUB_TOKEN')]) {
                        sh '''
                            # 1. 배포용 리포지토리 클론 (Token 인증)
                            # 안전한 방식: 토큰을 URL에 노출하지 않고 http.extraheader 를 사용합니다.
                            # Use token in URL with x-access-token username to ensure non-interactive clone works
                            # This is executed in CI; Jenkins masks the token in logs.
                            git clone https://x-access-token:$GITHUB_TOKEN@${DEPLOY_REPO_URL} deploy-repo-temp

                            # 2. 폴더 이동
                            cd deploy-repo-temp

                            # 3. Git 설정 (커밋 기록용)
                            git config user.email "jenkins@pipeline.com"
                            git config user.name "Jenkins Pipeline"

                            # 4. YAML 파일 내 이미지 태그 수정 (sed 명령어 사용)
                            # 주의: YAML 파일에서 image: 항목을 찾아 태그를 교체함
                            # 기존 내용 예시: image: active-webmaker/my-app-image:v1
                            sed -i "s|image: $DOCKER_REGISTRY_USER/$DOCKER_IMAGE_NAME:.*|image: $DOCKER_REGISTRY_USER/$DOCKER_IMAGE_NAME:$IMAGE_TAG|g" "$DEPLOY_YAML_PATH"

                            # 5. 변경 사항 확인
                            cat "$DEPLOY_YAML_PATH"

                            # 6. Git Commit & Push (파일에 변화가 있을 때만)
                            if [ -n "$(git status --porcelain)" ]; then
                                git add "$DEPLOY_YAML_PATH"
                                git commit -m "Update image tag to $IMAGE_TAG by Jenkins Build #$BUILD_NUMBER"
                                git push origin main
                            else
                                echo "No changes in $DEPLOY_YAML_PATH; skipping commit."
                            fi
                        '''
                    }
                }
            }
        }
    }

    // 파이프라인 종료 후 처리
    post {
        always {
            // 빌드 공간 정리 (Docker 이미지 등)
            sh "docker rmi ${env.DOCKER_REGISTRY_USER}/${env.DOCKER_IMAGE_NAME}:${env.IMAGE_TAG} || true"
            sh "rm -rf deploy-repo-temp || true"
        }
        success {
            echo 'Pipeline successfully completed.'
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}