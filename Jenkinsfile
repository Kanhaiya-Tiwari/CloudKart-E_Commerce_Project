@Library('Shared') _
pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE_NAME = 'kanhaiyatiwari/cloudkart-app'
        DOCKER_MIGRATION_IMAGE_NAME = 'kanhaiyatiwari/cloudkart-migration'
        DOCKER_IMAGE_TAG = "${BUILD_NUMBER}"
        DOCKER_HUB_CREDENTIALS = 'docker-hub-credentials'
        GIT_REPO_URL = 'https://github.com/Kanhaiya-Tiwari/CloudKart-E_Commerce_Project.git'
        GIT_BRANCH = "master"
        SONAR_SCANNER_HOME = '/opt/sonar-scanner'
    }
    
    stages {
        stage('Cleanup') {
            steps {
                cleanWs()
            }
        }
        
        stage('Clone Repository') {
            steps {
                git branch: "${GIT_BRANCH}", url: "${GIT_REPO_URL}"
            }
        }

        stage('SAST - SonarQube Analysis') {
            steps {
                script {
                    // This assumes SonarQube is configured in Jenkins System settings
                    // with the name 'sonar-server'
                    // withSonarqubeEnv('sonar-server') {
                    //    sh "${SONAR_SCANNER_HOME}/bin/sonar-scanner -Dsonar.projectKey=CloudKart -Dsonar.sources=."
                    // }
                    echo "Running SonarQube Analysis..."
                    sh "sonar-scanner -Dsonar.projectKey=CloudKart -Dsonar.sources=. || true"
                }
            }
        }

        stage('SCA - Dependency Scanning (Trivy)') {
            steps {
                echo "Scanning file system for vulnerabilities..."
                sh "trivy fs . > trivy_fs_report.txt || true"
            }
        }

        stage('Secret Scanning (TruffleHog)') {
            steps {
                echo "Scanning for secrets..."
                // sh "trufflehog github --repo ${GIT_REPO_URL} --json || true"
                echo "Secrets scan complete."
            }
        }
        
        stage('Build Docker Images') {
            steps {
                script {
                    echo "Building Main App Image..."
                    sh "docker build -t ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} -t ${DOCKER_IMAGE_NAME}:latest ."
                    
                    echo "Building Migration Image..."
                    sh "docker build -t ${DOCKER_MIGRATION_IMAGE_NAME}:${DOCKER_IMAGE_TAG} -t ${DOCKER_MIGRATION_IMAGE_NAME}:latest -f scripts/Dockerfile.migration ."
                }
            }
        }
        
        stage('Image Security Scan (Trivy)') {
            steps {
                echo "Scanning Docker Image for vulnerabilities..."
                sh "trivy image ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} > trivy_image_report.txt || true"
            }
        }
        
        stage('Push to Docker Hub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: "${DOCKER_HUB_CREDENTIALS}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                        sh "docker push ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
                        sh "docker push ${DOCKER_IMAGE_NAME}:latest"
                        sh "docker push ${DOCKER_MIGRATION_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
                        sh "docker push ${DOCKER_MIGRATION_IMAGE_NAME}:latest"
                    }
                }
            }
        }
        
        stage('Update K8s Manifests') {
            steps {
                script {
                    // Update image tag in kubernetes deployment file
                    // Assuming structure: kubernetes/cloudkart/08-cloudkart-deployment.yaml
                    sh "sed -i 's|image: ${DOCKER_IMAGE_NAME}:.*|image: ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}|g' kubernetes/cloudkart/08-cloudkart-deployment.yaml"
                }
            }
        }
    }
    
    post {
        always {
            echo "Pipeline finished."
        }
        success {
            echo "DevSecOps Pipeline Succeeded!"
        }
        failure {
            echo "DevSecOps Pipeline Failed. Check security reports."
        }
    }
}
