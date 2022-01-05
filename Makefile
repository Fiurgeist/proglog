CONFIG_PATH=${HOME}/.proglog
VERSION ?= 0.0.1

.PHONY: compile
compile:
	protoc api/v1/*.proto \
		--go_out=. \
		--go-grpc_out=. \
		--go_opt=paths=source_relative \
		--go-grpc_opt=paths=source_relative \
		--proto_path=.

.PHONY: init
init:
	mkdir -p ${CONFIG_PATH}

.PHONY: gencert
gencert:
	cfssl gencert \
		-initca test/ca-csr.json | cfssljson -bare ca

	cfssl gencert \
		-ca=ca.pem \
		-ca-key=ca-key.pem \
		-config=test/ca-config.json \
		-profile=server \
		test/server-csr.json | cfssljson -bare server

	cfssl gencert \
		-ca=ca.pem \
		-ca-key=ca-key.pem \
		-config=test/ca-config.json \
		-profile=client \
		test/client-csr.json | cfssljson -bare client

	cfssl gencert \
		-ca=ca.pem \
		-ca-key=ca-key.pem \
		-config=test/ca-config.json \
		-profile=client \
		-cn="root" \
		test/client-csr.json | cfssljson -bare root-client

	cfssl gencert \
		-ca=ca.pem \
		-ca-key=ca-key.pem \
		-config=test/ca-config.json \
		-profile=client \
		-cn="nobody" \
		test/client-csr.json | cfssljson -bare nobody-client

	mv *.pem *.csr ${CONFIG_PATH}

cp_model_conf:
	cp test/model.conf $(CONFIG_PATH)/model.conf

cp_policy_csv:
	cp test/policy.csv $(CONFIG_PATH)/policy.csv

.PHONY: test
test: cp_model_conf cp_policy_csv
	go test ./...

.PHONY: getservers
getservers:
	go run cmd/getservers/main.go

.PHONY: build-docker
build-docker:
	docker build -t github.com/fiurgeist/proglog:$(VERSION) .

help:
	@echo "  compile                  to compile the protobuf files"
	@echo "  init                     to create the config dir in $HOME"
	@echo "  gencert                  to create test certificates and move them to config dir"
	@echo "  test                     to test the source code"
	@echo "  build-docker             to build the docker image"
	@echo "  getservers               to run a script querying a list of all servers in the cluster"
