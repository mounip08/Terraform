pipeline {
    agent { label 'MavenAgents' }

    environment {
        IMAGE_NAME = "myapp3"
        IMAGE_TAG = "v2"
        SONARQUBE_URL = 'SonarQube_Server'
        AWS_REGION = 'us-east-1'
        AWS_ACCOUNT_ID = '490004634805'
        ECR_REPO = 'jenkinsrepo'
        ECR_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}"
    }

    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/vbc1012/java-war-repo.git'
            }
        }

        stage('Build with Maven') {
            steps {
                sh 'mvn clean package'
            }
        }
        
        stage('Run Unit Tests') {
            steps {
                sh 'mvn test'
            }
        }
        
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube_Server') {
                    sh 'mvn sonar:sonar'
                }
            }
        }

        stage('Quality Gate') {
            steps {
                script {
                    try {
                        timeout(time: 30, unit: 'SECONDS') {  
                            def qualityGate = waitForQualityGate()
                            if (qualityGate.status != 'OK') {
                                echo "⚠️ Quality Gate failed: ${qualityGate.status}, but pipeline will continue."
                            } else {
                                echo "✅ Quality Gate passed!"
                            }
                        }
                    } catch (Exception e) {
                        echo "⚠️ Quality Gate check timed out, but continuing the pipeline."
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                }
            }
        }

        stage('Run Docker Container') {  // Added Docker Run Step
            steps {
                script {
                    sh "docker run -d --name ${IMAGE_NAME}_container -p 8443:8443 ${IMAGE_NAME}:${IMAGE_TAG}"
                }
            }
        }

        stage('Login to ECR') {
            steps {
                script {
                    sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_URI}"
                }
            }
        }

        stage('Tag and Push Image') {
            steps {
                script {
                    sh """
                    docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${ECR_URI}:${IMAGE_TAG}
                    docker push ${ECR_URI}:${IMAGE_TAG}
                    """
                }
            }
        }
    }
}
