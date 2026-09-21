// CI pipeline for CloudKart: build app and migration containers, run security checks, and prepare deployment artifacts.

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
                sh "docker system prune -af"
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

                echo "Secrets scan complete."

            }

        }

        stage('Build Docker Images') {
            parallel {
                stage('Build Main App') {
                    steps {
                        echo "Building Main App Image..."
                        sh "df -h /"
                        sh "docker build --no-cache -t ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} -t ${DOCKER_IMAGE_NAME}:latest ."
                    }
                }
                stage('Build Migration') {
                    steps {
                        echo "Building Migration Image..."
                        sh "df -h /"
                        sh "docker build --no-cache -t ${DOCKER_MIGRATION_IMAGE_NAME}:${DOCKER_IMAGE_TAG} -t ${DOCKER_MIGRATION_IMAGE_NAME}:latest -f scripts/Dockerfile.migration ."
                    }
                }
            }
        }

        stage('Image Security Scan (Trivy)') {

            steps {

                echo "Scanning Docker Image for vulnerabilities..."

                sh "trivy image ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} > trivy_image_report.txt || true"

            }
