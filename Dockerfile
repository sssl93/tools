FROM python:3.7.4-alpine3.10

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
RUN apk add --no-cache vim apache2-utils curl socat iperf

COPY bin /opt/tools/bin
COPY scripts /opt/tools/scripts
COPY requirements.txt /opt/tools/requirements.txt

RUN pip install -r /opt/tools/requirements.txt -i https://pypi.douban.com/simple/ --trusted-host=pypi.douban.com/simple


WORKDIR /opt/tools

CMD ["sleep", "330600"]
