#/bin/bash

nmcli conn up $(nmcli conn show | awk 'NR > 1 {print $1}')

yum update -y

tee /etc/yum.repos.d/docker.repo <<-'EOF'
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF

yum install docker-engine -y
service docker start
docker run hello-world
systemctl enable docker

docker build -t kubia ../ -f ../Dockerfile

curl -Lo minikube https://storage.googleapis.com/minikube/releases/v0.23.0/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/bin/

minikube start --vm-driver=none

curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.8.7/bin/linux/amd64/kubectl && chmod +x kubectl && sudo mv kubectl /usr/bin/

kubectl run kubia --image=alexniu149/kubia --port=8080 --generator=run/v1
kubectl expose rc kubia --type=LoadBalancer --name kubia-http
kubectl scale rc kubia --replicas=3
