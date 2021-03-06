FROM python:3.7.4-alpine3.10

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
RUN apk add --no-cache musl-dev gcc vim apache2-utils curl socat iperf tcpdump net-tools

COPY bin /opt/tools/bin
COPY scripts /opt/tools/scripts
COPY k8s-examples /opt/tools/k8s-examples
COPY requirements.txt /opt/tools/requirements.txt

RUN pip install -r /opt/tools/requirements.txt -i https://pypi.douban.com/simple/ --trusted-host=pypi.douban.com/simple
RUN apk del musl-dev gcc


WORKDIR /opt/tools

CMD ["sleep", "330600"]
