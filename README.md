# Tools
some tools of developer.

* apache2-utils
* aiohttp web|req
* flask web
* webbench
* socat
* curl

Send udp datagram:
```
echo "hello" | socat - udp6-datagram:[2001:2::14e2:1dff:fe62:1e09]:9099
```

Send TCP data:
```
curl "http://\[2001:2::14e2:1dff:fe62:1e09\]:9099"
```

### Build go server

go build -o=/opt/tools/bin/go-server -ldflags "-s -w" -tags netgo -a  cmd/go-webserver/main.go

### Build go k8s

CGO_ENABLED=0 go build -o=/opt/tools/bin/go-k8s -ldflags "-s -w" -tags netgo -a  cmd/go-k8s/main.go