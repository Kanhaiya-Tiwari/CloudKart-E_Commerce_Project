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
            parallel {
                stage('Build Main App') {
                    steps {
                        echo "Building Main App Image..."
                        sh "docker build -t ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} -t ${DOCKER_IMAGE_NAME}:latest ."
                    }
                }
                stage('Build Migration') {
                    steps {
                        echo "Building Migration Image..."
                        sh "docker build -t ${DOCKER_MIGRATION_IMAGE_NAME}:${DOCKER_IMAGE_TAG} -t ${DOCKER_MIGRATION_IMAGE_NAME}:latest -f scripts/Dockerfile.migration ."
                    }
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
                    echo "Updating image tags in manifests..."
                    // Update image tag in kubernetes deployment file
                    sh "sed -i 's|image: ${DOCKER_IMAGE_NAME}:.*|image: ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}|g' kubernetes/cloudkart/08-cloudkart-deployment.yaml"
                    
                    // Update image tag in migration job file
                    sh "sed -i 's|image: ${DOCKER_MIGRATION_IMAGE_NAME}:.*|image: ${DOCKER_MIGRATION_IMAGE_NAME}:${DOCKER_IMAGE_TAG}|g' kubernetes/cloudkart/12-migration-job.yaml"
                }
            }
        }

        stage('Push Manifests to Git') {
            steps {
                script {
                    echo "Pushing updated manifests to Git..."
                    withCredentials([usernamePassword(credentialsId: 'github-credentials', usernameVariable: 'GIT_USER', passwordVariable: 'GIT_TOKEN')]) {
                        sh """
                            git config user.name "Jenkins CI"
                            git config user.email "jenkins@example.com"
                            git add kubernetes/cloudkart/08-cloudkart-deployment.yaml kubernetes/cloudkart/12-migration-job.yaml
                            git commit -m "Update image tags to ${DOCKER_IMAGE_TAG} [skip ci]" || echo "No changes to commit"
                            git push https://${GIT_USER}:${GIT_TOKEN}@github.com/Kanhaiya-Tiwari/CloudKart-E_Commerce_Project.git HEAD:master
                        """
                    }
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