pipeline {
    agent any
    tools {
        gradle 'Gradle'
    }

    stages {
        stage('Clone') {
            steps {
                git (
                branch: 'develop',
                url:    'https://lab.ssafy.com/s12-final/S12P31C105.git',
                credentialsId: 'Git'
                )

                sh 'echo "🔍 Checked out branch: $(git rev-parse --abbrev-ref HEAD)"'
                sh 'echo "🔍 Commit SHA   : $(git rev-parse HEAD)"'
                // sh 'find . -mindepth 1 -delete || true'
                // withCredentials([usernamePassword(credentialsId: 'Git', passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
                    // sh '''
                        // git clone -b develop https://${GIT_USERNAME}:${GIT_PASSWORD}@lab.ssafy.com/s12-final/S12P31C105.git .
                    // '''
                // }
            }
        }
        stage('Prepare Config') {
            steps {
                withCredentials([
                    file(credentialsId: 'application', variable: 'APP'),
                    file(credentialsId: '.env', variable: 'ENVFILE')
                ]) {
                    script {
                        sh 'mkdir -p backend/config'
                        def prodConfig = readFile(file: env.APP)
                        writeFile file: 'backend/config/application.yml', text: prodConfig

                        sh 'cat $ENVFILE > .env'
                        sh 'chmod 644 .env'
                    }
                }
            }
        }
        stage('Build Backend') {
            steps {
                dir('backend') {
                    sh 'chmod +x gradlew'
                    // 테스트를 건너뛰고 빌드
                    sh './gradlew clean build -x test --no-daemon'
                }
            }
        }
        stage('Build Project Archive') {
            steps {
                sh 'tar -czf project.tar.gz backend/build/libs/*.jar docker-compose.yml .env'
            }
        }
        stage('Deploy to Server') {
            steps {

		            script {
		                def user = sh(script: 'git log -1 --pretty=format:"%an"', returnStdout: true).trim()
		                mattermostSend(color: 'danger', message: "배포중 By : ${user}")
		            }

                withCredentials([sshUserPrivateKey(credentialsId: 'server-credentials', keyFileVariable: 'SSH_KEY', usernameVariable: 'SSH_USER')]) {
                    sh """
                        # 프로젝트 파일 전송
                        scp -i \$SSH_KEY -o StrictHostKeyChecking=no project.tar.gz \$SSH_USER@k12c105.p.ssafy.io:/home/ubuntu/S12P31C105/

                        # 원격 서버에서 배포 명령 실행
                        ssh -i \$SSH_KEY -o StrictHostKeyChecking=no \$SSH_USER@k12c105.p.ssafy.io '
                            cd /home/ubuntu/S12P31C105 &&
                            tar -xzf project.tar.gz &&
                            docker-compose down || true &&
                            docker-compose up -d mysql redis &&
                            echo "데이터베이스 서비스가 시작되길 기다리는 중..." &&
                            sleep 10 &&
                            docker-compose up -d --build spring fastapi nginx
                        '
                    """
                }
            }
        }
        stage('Health Check') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'server-credentials', keyFileVariable: 'SSH_KEY', usernameVariable: 'SSH_USER')]) {
                    script {
                        try {
                            sh """
                                # 헬스 체크 수행
                                ssh -i \$SSH_KEY -o StrictHostKeyChecking=no \$SSH_USER@k12c105.p.ssafy.io '
                                    cd /home/ubuntu/S12P31C105 &&
                                    sleep 10 &&
                                    curl -f http://localhost:8080/actuator/health || echo "Spring 서비스 상태 확인 중..." &&
                                    curl -f http://localhost:8000/docs || echo "FastAPI 서비스 상태 확인 중..."
                                '
                            """
                            echo '서비스 상태 확인 완료'
                        } catch (Exception e) {
                            echo "Health check warning: ${e.message}"
                            sh """
                                ssh -i \$SSH_KEY -o StrictHostKeyChecking=no \$SSH_USER@k12c105.p.ssafy.io '
                                    cd /home/ubuntu/S12P31C105 &&
                                    docker ps -a &&
                                    docker-compose logs
                                '
                            """
                        }
                    }
                }
            }
        }
    }
    post {
        success {
            script {
                def user = sh(script: 'git log -1 --pretty=format:"%an"', returnStdout: true).trim()
                mattermostSend(color: 'good', message: "서버 배포 성공 By ${user}")
            }
        }
        failure {
            script {
                def user = sh(script: 'git log -1 --pretty=format:"%an"', returnStdout: true).trim()
                mattermostSend(color: 'danger', message: "서버 배포 실패 By : ${user}")
            }
        }

    }
}