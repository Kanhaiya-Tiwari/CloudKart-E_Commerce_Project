@Library('Shared') _

pipeline {
    agent any
    
    environment {
        // Update the main app image name to match the deployment file
        DOCKER_IMAGE_NAME = 'kanhaiyatiwari/cloudkart-app'
        DOCKER_MIGRATION_IMAGE_NAME = 'kanhaiyatiwari/cloudkart-migration'
        DOCKER_IMAGE_TAG = "${BUILD_NUMBER}"
        GITHUB_CREDENTIALS = credentials('github-credentials')
        GIT_BRANCH = "master"
    }
    
    stages {
        stage('Cleanup Workspace') {
            steps {
                script {
                    clean_ws()
                }
            }
        }
        
        stage('Clone Repository') {
            steps {
                script {
                    clone("https://github.com/Kanhaiya-Tiwari/CloudKart-E_Commerce_Project.git","master")
                }
            }
        }
        
        stage('Build Docker Images') {
            parallel {
                stage('Build Main App Image') {
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
                
                stage('Build Migration Image') {
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
        
        stage('Run Unit Tests') {
            steps {
                script {
                    run_tests()
                }
            }
        }
        
        stage('Security Scan with Trivy') {
            steps {
                script {
                    trivy_scan()
                }
            }
        }
        
        stage('Push Docker Images') {
            parallel {
                stage('Push Main App Image') {
                    steps {
                        script {
                            docker_push(
                                imageName: env.DOCKER_IMAGE_NAME,
                                imageTag: env.DOCKER_IMAGE_TAG,
                                credentials: 'docker-hub-credentials'
                            )
                        }
                    }
                }
                
                stage('Push Migration Image') {
                    steps {
                        script {
                            docker_push(
                                imageName: env.DOCKER_MIGRATION_IMAGE_NAME,
                                imageTag: env.DOCKER_IMAGE_TAG,
                                credentials: 'docker-hub-credentials'
                            )
                        }
                    }
                }
            }
        }
        
        stage('Update Kubernetes Manifests') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'github-credentials', passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
                        sh """
                            git config user.name "Jenkins CI"
                            git config user.email "jenkins@cloudkart.com"
                            
                            # Update App Deployment Image
                            sed -i 's|image: kanhaiyatiwari/cloudkart-app:.*|image: kanhaiyatiwari/cloudkart-app:${DOCKER_IMAGE_TAG}|g' kubernetes/08-cloudkart-deployment.yaml
                            
                            # Update Migration Job Image
                            sed -i 's|image: kanhaiyatiwari/cloudkart-migration:.*|image: kanhaiyatiwari/cloudkart-migration:${DOCKER_IMAGE_TAG}|g' kubernetes/12-migration-job.yaml
                            
                            git add kubernetes/08-cloudkart-deployment.yaml kubernetes/12-migration-job.yaml
                            git commit -m "Update images to version ${DOCKER_IMAGE_TAG} [skip ci]" || echo "No changes to commit"
                            git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/Kanhaiya-Tiwari/CloudKart-E_Commerce_Project.git master
                        """
                    }
                }
            }
        }
    }
}
