This is based on the book Distributed Services with Go by [Travis Jeffery](https://github.com/travisjeffery), [also see](https://github.com/travisjeffery/proglog).

# Setup
## Replaced libs
* Using ectd's fork of Bolt which includes fixes for Go 1.14+
  * $ go mod edit -replace github.com/hashicorp/raft-boltdb=github.com/travisjeffery/raft-boltdb@v1.0.0
## Protobuf
* $ wget https://github.com/protocolbuffers/protobuf/releases/download/v3.19.1/protoc-3.19.1-linux-x86_64.zip
* $ unzip protoc-3.19.1-linux-x86_64.zip -d /usr/local/protbuf
* $ go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.27.1
* $ go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.2.0
## KinD
* $ curl -Lo ./kind https://github.com/kubernetes-sigs/kind/releases/download/v0.11.1/kind-linux-amd64
* $ chmod +x ./kind
* $ mv ./kind /usr/local/bin/
## Helm
* $ curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Run tests
## Setup
* $ go install github.com/cloudflare/cfssl/cmd/cfssl@v1.6.1 github.com/cloudflare/cfssl/cmd/cfssljson@v1.6.1
* $ make init
* $ make gencert
## Run
* $ make test

# Run locally
* $ make build-docker
* $ kind create cluster
* $ kind load docker-image github.com/fiurgeist/proglog:0.0.1
* $ helm install proglog deploy/proglog

# Run in Google Cloud
## Setup
* create Kubernetes cluster in GCP with name proglog
* install gcloud CLI
## Push to Cloud
* $ gcloud auth login
* $ PROJECT_ID=$(gcloud projects list | tail -n 1 | cut -d' ' -f1)
* $ gcloud config set project $PROJECT_ID
* $ gcloud auth configure-docker
  * updates ~/.docker/config.json
* $ docker tag github.com/fiurgeist/proglog:0.0.1 eu.gcr.io/$PROJECT_ID/proglog:0.0.1
* $ docker push eu.gcr.io/$PROJECT_ID/proglog:0.0.1
## Deploy with Helm
* $ gcloud container cluster get-credentials proglog --zone europe-west3-c
  * updates ~/.kube/config.json with credentials and endpoints
* $ cd delpoy
* $ kubectl create namespace metacontroller
* $ helm install metacontroller metacontroller
* $ helm install proglog proglog --set image.repository=eu.grc.io/$PROJECT_ID/proglog --set service.lb=true