VERSION="v1.0.0"
REGISTRY="beyond.io:5000/fabric/x-tools"

docker build -t ${REGISTRY}x-tools:${VERSION} .
docker push ${REGISTRY}x-tools:${VERSION}