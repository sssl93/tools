# buildkitd.toml
#[registry."beyond.io:5000"]
#  http = true
#  insecure = true

#docker run --rm --privileged docker/binfmt:a7996909642ee92942dcd6cff44b9b95f08dad64
#docker buildx create --use --name mybuilder --driver-opt network=host --config=/etc/buildkit/buildkitd.toml
#docker buildx inspect mybuilder --bootstrap

# docker image inspect xxx |grep Arch

mkdir -p /etc/buildkit
touch /etc/buildkit/buildkitd.toml

cat >> /etc/buildkit/buildkitd.toml <<EOF
debug = true
[registry."beyond.io:5000"]
  http = true
[registry."deploy.bocloud.k8s:5001"]
  http = true
EOF

docker run --privileged --rm tonistiigi/binfmt --uninstall qemu-* && \
	docker run --privileged --rm tonistiigi/binfmt --install all && \
	docker buildx rm mybuilder

docker buildx create --use --name mybuilder --config /etc/buildkit/buildkitd.toml --buildkitd-flags '--allow-insecure-entitlement network.host security.insecure' --driver-opt network=host  && \
     	docker buildx inspect mybuilder --bootstrap && \
    	docker buildx ls

