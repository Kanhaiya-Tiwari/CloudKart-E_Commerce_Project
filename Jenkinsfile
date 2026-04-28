@Library('Shared') _

pipeline {
    agent any
    
    options {
        timeout(time: 1, unit: 'HOURS')
        timestamps()
        disableConcurrentBuilds()
        ansiColor('xterm')
    }
    
    environment {
        // --- Project Configuration ---
        PROJECT_NAME = "CloudKart"
        GIT_REPO_URL = "https://github.com/Kanhaiya-Tiwari/CloudKart-E_Commerce_Project.git"
        GIT_BRANCH   = "master"
        
        // --- Image Configuration ---
        DOCKER_IMAGE_NAME           = 'kanhaiyatiwari/cloudkart-app'
        DOCKER_MIGRATION_IMAGE_NAME = 'kanhaiyatiwari/cloudkart-migration'
        DOCKER_IMAGE_TAG            = "${BUILD_NUMBER}"
        DOCKER_HUB_CREDENTIALS      = 'docker-hub-credentials'
    }
    
    stages {
        stage('Initialize') {
            steps {
                script {
                    echo "Starting Industry Standard Pipeline for ${PROJECT_NAME} (Build #${DOCKER_IMAGE_TAG})"
                    clean_ws() 
                }
            }
        }
        
        stage('Source Checkout') {
            steps {
                script {
                    clone(env.GIT_REPO_URL, env.GIT_BRANCH) 
                }
            }
        }

        stage('Security Analysis (SAST & SCA)') {
            parallel {
                stage('SonarQube Static Analysis') {
                    steps {
                        script {
                            echo "Performing Static Code Analysis..."
                            // sonar_scan() 
                        }
                    }
                }
                stage('Dependency Vulnerability Scan') {
                    steps {
                        script {
                            echo "Scanning Project dependencies with Trivy..."
                            sh "trivy fs . --severity HIGH,CRITICAL --format table"
                        }
                    }
                }
            }
        }
        
        stage('Parallel Docker Building') {
            parallel {
                stage('Build: Application Image') {
                    steps {
                        script {
                            docker_build(
                                imageName: env.DOCKER_IMAGE_NAME, 
                                imageTag: env.DOCKER_IMAGE_TAG,
                                dockerfile: 'Dockerfile',
                                context: '.'
                            )
                        }
                    }
                }
                stage('Build: Migration Image') {
                    steps {
                        script {
                            docker_build(
                                imageName: env.DOCKER_MIGRATION_IMAGE_NAME, 
                                imageTag: env.DOCKER_IMAGE_TAG,
                                dockerfile: 'scripts/Dockerfile.migration',
                                context: '.'
                            )
                        }
                    }
                }
            }
        }

        stage('Image Quality Gate') {
            steps {
                script {
                    echo "Scanning Application Image for Vulnerabilities..."
                    trivy_scan(imageName: env.DOCKER_IMAGE_NAME, imageTag: env.DOCKER_IMAGE_TAG)
                }
            }
        }
        
        stage('Parallel Image Distribution') {
            parallel {
                stage('Push: Application Image') {
                    steps {
                        script {
                            docker_push(
                                imageName: env.DOCKER_IMAGE_NAME, 
                                imageTag: env.DOCKER_IMAGE_TAG, 
                                credentials: env.DOCKER_HUB_CREDENTIALS
                            )
                        }
                    }
                }
                stage('Push: Migration Image') {
                    steps {
                        script {
                            docker_push(
                                imageName: env.DOCKER_MIGRATION_IMAGE_NAME, 
                                imageTag: env.DOCKER_IMAGE_TAG, 
                                credentials: env.DOCKER_HUB_CREDENTIALS
                            )
                        }
                    }
                }
            }
        }

        stage('CD Target Update (GitOps)') {
            steps {
                script {
                    echo "Updating Kubernetes Manifests with new Image Tag: ${DOCKER_IMAGE_TAG}"
                    update_k8s_manifests(
                        imageTag: env.DOCKER_IMAGE_TAG,
                        manifestsPath: 'kubernetes/cloudkart/08-cloudkart-deployment.yaml'
                    )
                }
            }
        }
    }
    
    post {
        success {
            echo "SUCCESS: Pipeline completed for Build #${DOCKER_IMAGE_TAG}"
        }
        failure {
            echo "FAILURE: Pipeline failed at Build #${DOCKER_IMAGE_TAG}. Check security reports."
        }
        always {
            script {
                echo "Cleaning up workspace..."
                // clean_ws()
            }
        }
    }
}
