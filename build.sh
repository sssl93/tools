VERSION="v1.0.4"
REGISTRY="beyond.io:5000/fabric/"

go build -o=bin/go-server -ldflags "-s -w" -tags netgo -a  cmd/go-webserver/main.go
CGO_ENABLED=0 go build -o=bin/go-k8s -ldflags "-s -w" -tags netgo -a  cmd/go-k8s/main.go

docker build -t ${REGISTRY}x-tools:${VERSION} .
docker push ${REGISTRY}x-tools:${VERSION}
