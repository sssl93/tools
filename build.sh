VERSION="v1.0.0"
REGISTRY="10.20.51.147:4000/"

docker build -t ${REGISTRY}x-tools:${VERSION} .
docker push ${REGISTRY}x-tools:${VERSION}