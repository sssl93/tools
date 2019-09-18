from socket import *
from time import ctime

host = ''
port = 9089
buf_size = 1024
addr = (host, port)

udpServer = socket(AF_INET, SOCK_DGRAM)
udpServer.bind(addr)

with udpServer:
    while True:
        print('Waiting for connection...')
        data, addr = udpServer.recvfrom(buf_size)
        data = data.decode(encoding='utf-8').upper()
        print(f'{addr} Connected: {data}')

        reply_data = "at %s :%s" % (ctime(), data)
        udpServer.sendto(reply_data.encode(encoding='utf-8'), addr)
        print(f'Send to {addr}: {reply_data}')
