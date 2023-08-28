import socket as s


server = s.socket(s.AF_INET, s.SOCK_STREAM)
server.connect(('localhost', 7175))

while True:
	server.send(input('Alice: ').encode())

	msg = server.recv(1024)
	print(msg)
