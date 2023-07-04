pipeline {
    agent any
    environment {
        repository = 'platformsi/spring-test' // Docker Hub ID와 repository 이름
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-platformsi') // Jenkins에 등록해 놓은 Docker Hub credentials 이름
        dockerImage = ''
        kubeconfig = '/home/config' // Kubernetes 구성 파일 경로
    }

    tools {
        maven 'maven_jenkins'
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/94tiger/spring-test-2.git'
                // git 'https://github.com/94tiger/spring-test-2.git'
            }
        }

        stage('Maven 빌드') {
            steps {
                sh 'mvn -version'
                sh 'mvn clean install -DskipTests'
                // JAR 파일을 Docker 이미지 빌드 경로로 복사
                // sh 'cp target/demo-0.0.1-SNAPSHOT.jar /var/jenkins_home/workspace/Spring\\ Boot\\ Test/app.jar'
            }
        }

        stage('Docker Image 빌드') {
            steps {
                script {
                    sh 'docker ps'
                    // sh 'mv target/demo-0.0.1-SNAPSHOT.jar app.jar'
                    // sh 'mv app.jar app.jar'
                    // dockerImage = docker.build repository + ":latest"
				    def imageTag = env.BUILD_NUMBER // build number를 이미지 태그로 사용
                    dockerImage = docker.build repository + ":" + imageTag // 이미지 태그에 build number 추가
                }
            }
        }

        stage('Docker Hub 업로드') {
            steps {
                script {
                    sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u platformsi --password-stdin' // docker hub 로그인
					// sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u platformsi --password-stdin' // docker hub 로그인
                    // sh 'docker push $repository:latest' //docker push
                    // sh 'docker push $repository:$BUILD_NUMBER' //docker push
				    sh "docker push ${repository}:${env.BUILD_NUMBER}" // build number에 해당하는 이미지를 업로드
				    sh "docker push ${repository}:latest" // build number에 해당하는 이미지를 업로드
                }
            }
        }

        stage('Kubernetes 배포') {

            steps {
                script {
                    // Kubernetes에 배포할 YAML 파일 생성
                    sh 'echo "apiVersion: v1\nkind: Service\nmetadata:\n  name: spring-test-service\nspec:\n  type: NodePort\n  selector:\n    app: spring-test\n  ports:\n    - protocol: TCP\n      port: 8080\n      targetPort: 8080" > service.yaml'

                    // Kubernetes 클러스터에 배포
                    sh 'kubectl --insecure-skip-tls-verify --kubeconfig $kubeconfig apply -f service.yaml --force'
                    // sh 'kubectl --insecure-skip-tls-verify apply -f service.yaml'
				    // sh "kubectl --insecure-skip-tls-verify --kubeconfig $kubeconfig set image deployment/spring-test-deployment2 spring-test-container=${repository}:${env.BUILD_NUMBER}" // build number에 해당하는 이미지를 배포

				    // 이미지 Pull
                    sh "kubectl --insecure-skip-tls-verify --kubeconfig /home/config set image deployment/spring-test spring-test=${repository}:${env.BUILD_NUMBER}"
                    // sh 'kubectl --insecure-skip-tls-verify --kubeconfig /home/config set image deployment/spring-test=spring-test=platformsi/spring-test:${env.BUILD_NUMBER}'

                    // 리소스 재배포
                    sh 'kubectl --insecure-skip-tls-verify --kubeconfig /home/config rollout restart deployment/spring-test'
                }
            }
        }
    }
}