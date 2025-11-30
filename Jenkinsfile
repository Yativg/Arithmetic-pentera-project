pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE_NAME = 'arithmetic-server'
        DOCKER_REGISTRY = 'docker.io'
        DOCKER_CREDENTIALS_ID = 'dockerhub-credentials'
        DOCKER_USERNAME = 'yativg'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        IMAGE_TAG_LATEST = 'latest'
        FULL_IMAGE_NAME = "${DOCKER_REGISTRY}/${DOCKER_USERNAME}/${DOCKER_IMAGE_NAME}"
    }
    
    stages {
        stage('Preparation') {
            steps {
                script {
                    try {
                        echo "Starting Build #${env.BUILD_NUMBER}"
                        cleanWs()
                        checkout scm
                        sh '''
                            set +x
                            echo "Validating required files..."
                            [ -f Dockerfile ] && [ -d src ] && [ -f src/server.py ] && \
                            [ -f src/client.py ] && [ -f src/operations.py ] || \
                            { echo "ERROR: Required files missing"; exit 1; }
                            echo "All files present"
                        '''
                        echo "✅ Preparation complete"
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        error("Preparation failed: ${e.message}")
                    }
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    try {
                        echo "Building ${FULL_IMAGE_NAME}:${IMAGE_TAG}"
                        sh """
                            set +x
                            docker build --tag ${FULL_IMAGE_NAME}:${IMAGE_TAG} --tag ${FULL_IMAGE_NAME}:${IMAGE_TAG_LATEST} . | tail -5
                        """
                        echo "✅ Build complete"
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        error("Build failed: ${e.message}")
                    }
                }
            }
        }
        
        stage('Test Docker Image') {
            steps {
                script {
                    try {
                        echo "Testing image..."
                        sh """
                            set +x
                            docker stop arithmetic-server arithmetic-server-test-${BUILD_NUMBER} 2>/dev/null || true
                            docker rm arithmetic-server arithmetic-server-test-${BUILD_NUMBER} 2>/dev/null || true
                            echo "Starting test container..."
                            docker run -d --name arithmetic-server-test-${BUILD_NUMBER} -p 5555:5555 ${FULL_IMAGE_NAME}:${IMAGE_TAG} >/dev/null
                            sleep 5
                            echo "Running connectivity test..."
                            docker exec arithmetic-server-test-${BUILD_NUMBER} python3 -c "import socket, json, sys; s = socket.socket(socket.AF_INET, socket.SOCK_STREAM); s.settimeout(10); s.connect(('localhost', 5555)); s.sendall(json.dumps({'num1': 10, 'num2': 5, 'operation': '+'}).encode('utf-8')); response = json.loads(s.recv(1024).decode('utf-8')); s.close(); assert response['status'] == 'success' and response['result'] == 15; print('✅ Test passed: 10 + 5 = 15')" || exit 1
                        """
                        echo "✅ Tests passed"
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        error("Testing failed: ${e.message}")
                    } finally {
                        sh "set +x; docker stop arithmetic-server-test-${BUILD_NUMBER} 2>/dev/null || true"
                        sh "set +x; docker rm arithmetic-server-test-${BUILD_NUMBER} 2>/dev/null || true"
                    }
                }
            }
        }
        
        stage('Push to Registry') {
            steps {
                script {
                    try {
                        echo "Pushing to ${FULL_IMAGE_NAME}"
                        withCredentials([usernamePassword(
                            credentialsId: DOCKER_CREDENTIALS_ID,
                            usernameVariable: 'DOCKER_USER',
                            passwordVariable: 'DOCKER_PASS'
                        )]) {
                            sh "set +x; echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin ${DOCKER_REGISTRY} 2>&1 | grep -v 'WARNING'"
                        }
                        sh "docker push ${FULL_IMAGE_NAME}:${IMAGE_TAG} | tail -3"
                        sh "docker push ${FULL_IMAGE_NAME}:${IMAGE_TAG_LATEST} | tail -3"
                        echo "✅ Push complete"
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        error("Push failed: ${e.message}")
                    } finally {
                        sh 'docker logout ${DOCKER_REGISTRY} 2>/dev/null || true'
                    }
                }
            }
        }
        
        stage('Deploy') {
            steps {
                script {
                    try {
                        echo "Deploying container..."
                        sh """
                            set +x
                            docker stop arithmetic-server 2>/dev/null || true
                            docker rm arithmetic-server 2>/dev/null || true
                            echo "Starting container: arithmetic-server"
                            docker run -d --name arithmetic-server --restart unless-stopped -p 5555:5555 ${FULL_IMAGE_NAME}:${IMAGE_TAG} >/dev/null
                            sleep 3
                        """
                        echo "✅ Deployed: ${FULL_IMAGE_NAME}:${IMAGE_TAG}"
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        error("Deployment failed: ${e.message}")
                    }
                }
            }
        }
        
        stage('Verify') {
            steps {
                script {
                    try {
                        echo "Running verification tests..."
                        sh '''
                            set +x
                            python3 - <<'EOF'
import socket, json, sys

print("=" * 60)
print("VERIFICATION TESTS")
print("=" * 60)

tests = [
    (10, 5, '+', 15, "Addition"),
    (20, 8, '-', 12, "Subtraction"),
    (6, 7, '*', 42, "Multiplication"),
    (100, 4, '/', 25.0, "Division"),
    (15, 3, '/', 5.0, "Division (exact)"),
    (100, 0, '+', 100, "Add zero"),
    (50, 50, '-', 0, "Subtract equal"),
    (99, 1, '*', 99, "Multiply by one")
]

passed = 0
for i, (num1, num2, op, expected, desc) in enumerate(tests, 1):
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(5)
        s.connect(('localhost', 5555))
        s.sendall(json.dumps({'num1': num1, 'num2': num2, 'operation': op}).encode('utf-8'))
        response = json.loads(s.recv(1024).decode('utf-8'))
        s.close()
        if response['status'] == 'success' and response['result'] == expected:
            print(f"✅ Test {i}/{len(tests)}: {desc} - {num1} {op} {num2} = {expected}")
            passed += 1
        else:
            print(f"❌ Test {i}/{len(tests)}: {desc} - Expected {expected}, got {response.get('result')}")
    except Exception as e:
        print(f"❌ Test {i}/{len(tests)}: {desc} - Failed: {e}")

print("=" * 60)
print(f"RESULT: {passed}/{len(tests)} tests passed")
print("=" * 60)
sys.exit(0 if passed == len(tests) else 1)
EOF
                        '''
                        echo "✅ Verification complete"
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        error("Verification failed: ${e.message}")
                    }
                }
            }
        }
    }
    
    post {
        success {
            echo "✅ Pipeline completed successfully"
        }
        failure {
            echo "❌ Pipeline failed - Build #${env.BUILD_NUMBER}"
        }
        always {
            sh 'set +x; docker images arithmetic-server --format "{{.ID}}" 2>/dev/null | tail -n +6 | xargs -r docker rmi -f 2>/dev/null || true'
            cleanWs()
        }
    }
}
