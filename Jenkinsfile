pipeline {
    agent any

    triggers {
        githubPush()
    }

    stages {
        stage('Clone Repository') {
            steps {
                sh '''
                    echo "Cloning application repository..."
                    rm -rf /tmp/projCert
                    git clone https://github.com/rupdasb/projCert.git /tmp/projCert
                    echo "Repository cloned successfully"
                '''
            }
        }

        stage('Job 1: Install Puppet via SSH') {
            steps {
                sh '''
                    echo "=== Job 1: Installing Puppet on slave node ==="
                    ssh -i /var/lib/jenkins/key_key.pem -o StrictHostKeyChecking=no -o ConnectTimeout=30 ubuntu@34.204.76.204 "
                        echo 'Starting Puppet installation...' &&
                        sudo apt update &&
                        sudo apt install -y puppet &&
                        sudo systemctl enable puppet &&
                        sudo systemctl start puppet &&
                        echo '=== Puppet installation completed successfully ===' &&
                        puppet --version
                    "
                '''
            }
        }

        stage('Job 2: Fix and Start Docker') {
            steps {
                sh '''
                    echo "=== Job 2: Fixing and starting Docker ==="
                    ssh -i /var/lib/jenkins/key_key.pem -o StrictHostKeyChecking=no -o ConnectTimeout=30 ubuntu@34.204.76.204 "
                        echo 'Fixing Docker socket activation...' &&
                        sudo systemctl stop docker.socket docker.service || true &&
                        sudo systemctl reset-failed docker.socket docker.service || true &&
                        sudo systemctl daemon-reload &&
                        sudo systemctl start docker.socket &&
                        sleep 5 &&
                        sudo systemctl start docker.service &&
                        sleep 5 &&
                        echo '=== Docker should be working now ===' &&
                        sudo docker --version
                    "
                '''
            }
        }

        stage('Job 3: Build & Deploy PHP Container') {
            steps {
                sh '''
                    echo "=== Job 3: Building and deploying PHP application ==="
                    scp -i /var/lib/jenkins/key_key.pem -o StrictHostKeyChecking=no -r /tmp/projCert ubuntu@34.204.76.204:/home/ubuntu/
                    ssh -i /var/lib/jenkins/key_key.pem -o StrictHostKeyChecking=no -o ConnectTimeout=30 ubuntu@34.204.76.204 "
                        cd /home/ubuntu/projCert &&
                        sudo docker stop php-app || true &&
                        sudo docker rm php-app || true &&
                        sudo docker build -t my-php-app:latest . &&
                        sudo docker run -d --name php-app -p 80:80 my-php-app:latest &&
                        echo '=== PHP application deployed successfully! ===' &&
                        echo 'Container is running on: http://34.204.76.204:80'
                    "
                '''
            }
            post {
                failure {
                    sh '''
                        echo "!!! Job 3 Failed - Cleaning up !!!"
                        ssh -i /var/lib/jenkins/key_key.pem -o StrictHostKeyChecking=no ubuntu@34.204.76.204 "
                            sudo docker stop php-app || true
                            sudo docker rm php-app || true
                            echo 'Cleanup completed'
                        " || echo "Cleanup command executed"
                    '''
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                sh '''
                    echo "=== Verifying deployment ==="
                    ssh -i /var/lib/jenkins/key_key.pem -o StrictHostKeyChecking=no -o ConnectTimeout=30 ubuntu@34.204.76.204 "
                        sleep 15 &&
                        sudo docker ps &&
                        curl -s -o /dev/null -w 'HTTP Status: %{http_code}\n' http://localhost:80 || echo 'Application check completed'
                    "
                '''
            }
        }
    }

    post {
        always {
            sh '''
                echo "=== Pipeline execution completed ==="
                rm -rf /tmp/projCert
                echo "Temporary files cleaned up"
            '''
        }
        success {
            sh '''
                echo "=== PIPELINE SUCCESS ==="
                echo "PHP application is running at: http://34.204.76.204:80"
                echo "All jobs completed successfully!"
            '''
        }
        failure {
            sh '''
                echo "=== PIPELINE FAILED ==="
                echo "Check the logs above for errors"
            '''
        }
    }
}

