import socket


sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

sock.connect((socket.gethostbyname('www.videolan.org'), 80))

req = 'GET / HTTP/1.1\r\n' + 'HOST: www.videolan.org\r\n\r\n'
sock.sendall(req.encode())


a = sock.recv(1024).decode()
data = ''

while a != '':
    data += a
    a = sock.recv(1024).decode()
    print(a)

print(data)

sock.close()
