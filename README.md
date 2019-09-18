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