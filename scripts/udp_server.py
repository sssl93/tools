from socket import *
from time import ctime
import argparse
import threading

parser = argparse.ArgumentParser(description='UDP server optional args.')
parser.add_argument("--host", help="listen host address.", type=str,
                    default="")
parser.add_argument("--udpPort", help="listen udp port.", type=int,
                    default=8088)
parser.add_argument("--tcpPort", help="listen tcp port.", type=int,
                    default=8098)
args = parser.parse_args()

host = args.host
udp_port = args.udpPort
tcp_port = args.tcpPort
buf_size = 1024


def run_udp_server():
    addr = (host, udp_port)
    udp_server = socket(AF_INET, SOCK_DGRAM)
    udp_server.bind(addr)

    with udp_server:
        while True:
            print(f'UDP Service {addr} Waiting for connection...')
            data, addr = udp_server.recvfrom(buf_size)
            data = data.decode(encoding='utf-8').upper()
            print(f'{addr} Connected: {data}')

            reply_data = "at %s :%s" % (ctime(), data)
            udp_server.sendto(reply_data.encode(encoding='utf-8'), addr)
            print(f'Send to {addr}: {reply_data}')


def run_tcp_server():
    addr = (host, tcp_port)
    tcp_server = socket(AF_INET, SOCK_STREAM)
    tcp_server.bind(addr)
    tcp_server.listen(5)

    with tcp_server:
        while True:
            print(f'TCP Service {addr} Waiting for connection...')
            ss, cli_addr = tcp_server.accept()
            data = ss.recv(buf_size).decode(encoding='utf-8').upper()
            print(f'{addr} Connected: {data}')

            reply_data = "at %s :%s" % (ctime(), data)
            with ss:
                ss.send(reply_data.encode(encoding='utf-8'))
                print(f'Send to {addr}: {reply_data}')


def main():
    tcp_thread = threading.Thread(target=run_tcp_server, daemon=True)
    tcp_thread.start()
    run_udp_server()


if __name__ == "__main__":
    main()
