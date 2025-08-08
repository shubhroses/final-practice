#!/bin/bash
set -euo pipefail

PROJECT_DIR="/home/vagrant/final-practice"
DIR_PATH="https://github.com/shubhroses/final-practice.git"

echo ""
echo "1. Ensure Vagrant is up and running"
vagrant up --provide=qemu

echo ""
echo "2. Pull / Clone from git"
vagrant ssh -c "
    if [ -d ${PROJECT_DIR} ]; then
        cd ${PROJECT_DIR} && git pull origin main
    else
        git clone ${DIR_PATH} ${PROJECT_DIR}
    fi
"

echo ""
echo "3. Build docker image and push to docker hub"
# vagrant ssh -c "cd ${PROJECT_DIR} &&  docker build -t flask-demo ."
vagrant ssh -c "cd ${PROJECT_DIR} &&  docker build -t flask-demo:latest . && docker tag flask-demo:latest docker.io/shubhroses/flask-demo:latest"
vagrant ssh -c "cd ${PROJECT_DIR} && docker push docker.io/shubhroses/flask-demo:latest"

echo ""
echo "4. Import docker image to k3s"
# vagrant ssh -c "docker save flask-demo | sudo k3s ctr images import -"


echo ""
echo "5. Apply k8s-deploy.yaml file"
vagrant ssh -c "cd ${PROJECT_DIR} &&  sudo k3s kubectl apply -f k8s-deploy.yaml"

echo ""
echo "6. Restart pods"
vagrant ssh -c "cd ${PROJECT_DIR} &&  sudo k3s kubectl rollout restart deployment/flask-demo"

echo ""
echo "7. Wait for restart to complete"
vagrant ssh -c "cd ${PROJECT_DIR} &&  sudo k3s kubectl rollout status deployment/flask-demo --timeout 60s"


echo ""
echo "8. Test application"
vagrant ssh -c "curl http://localhost:30007"