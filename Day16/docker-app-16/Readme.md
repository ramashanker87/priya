
sudo usermod -aG docker $USER
newgrp docker

## Start Application

    python app.py

## Create docker images

    docker build -f Dockerfile.multi -t priya-hello-ecr:v2 .

## Lab 4: Run Container

```bash
docker run -d --name priya-hello-app -p 8080:8080 priya-hello-ecr:v2
curl http://localhost:8080
```

---

## Stop Docker container
    
    docker stop <container-id>

## Remove Docker container

    docker rm <container-id>

## Docker Compose

    Create Docker compose file 

``` 
version: "3.8"

services:
  hello-app:
    image: priya-hello-ecr:v2
    container_name: priya-hello-app
    ports:
      - "8080:8080"
    restart: unless-stopped
```
## Install docker compose if it has not been installed:
   sudo apt  install docker-compose

## Start the conrtainer with docker compose

    docker compose up

## Stop the container with docker compose 

    docker compose down


## Lab 6: Create ECR Repository

```bash
aws ecr create-repository \
--repository-name priya-ecr \
--region us-east-1 --profile devops
```

---

## Lab 7: Authenticate Docker

```bash
aws ecr get-login-password \
--region us-east-1 --profile devops | \
docker login \
--username AWS \
--password-stdin \
386757865964.dkr.ecr.us-east-1.amazonaws.com
```

---

## Lab 8: Tag Image

```bash
docker tag priya-hello-ecr:v2 \
386757865964.dkr.ecr.us-east-1.amazonaws.com/priya-ecr:v2
```

---

## Lab 9: Push Image to ECR

```bash
docker push \
386757865964.dkr.ecr.us-east-1.amazonaws.com/priya-ecr:v2
```

---

## Lab 10: Verify Images

```bash
aws ecr list-images \
--repository-name priya-ecr \
--region us-east-1 --profile devops
```

---
