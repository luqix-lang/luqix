module lSocket;


import std.socket;
import std.conv: to;

import std.uni: toLower;
import std.stdio: writeln;
import std.format: format;


import LdObject;

alias LdOBJECT[string] HEAP;

class oSocket: LdOBJECT
{
	HEAP props;

	this(){
		this.props = [
			"Socket": new new_socket(),

			"getaddrinfo": new GetAdrrInfo(),
			"gethostbyname": new GetHostByName(),
			"gethostbyaddr": new GetHostByAddr(),


			"SOCK_STREAM": new LdNum(SocketType.STREAM),
			"SOCK_RAW": new LdNum(SocketType.RAW),
			"SOCK_RDM": new LdNum(SocketType.RDM),
			"SOCK_SEQPACKET": new LdNum(SocketType.SEQPACKET),
			"SOCK_DGRAM": new LdNum(SocketType.DGRAM),


			"AF_INET": new LdNum(AddressFamily.INET),
			"AF_INET6": new LdNum(AddressFamily.INET6),
			"AF_IPX": new LdNum(AddressFamily.IPX),
			"AF_UNIX": new LdNum(AddressFamily.UNIX),
			"AF_UNSPEC": new LdNum(AddressFamily.UNSPEC),
			"AF_APPLETALK": new LdNum(AddressFamily.APPLETALK),

			"IPPROTO_IP": new LdNum(ProtocolType.IP),
			"IPPROTO_ICMP": new LdNum(ProtocolType.ICMP),
			"IPPROTO_IGMP": new LdNum(ProtocolType.IGMP),
			"IPPROTO_GGP": new LdNum(ProtocolType.GGP),
			"IPPROTO_TCP": new LdNum(ProtocolType.TCP),
			"IPPROTO_PUP": new LdNum(ProtocolType.PUP),
			"IPPROTO_UDP": new LdNum(ProtocolType.UDP),
			"IPPROTO_IDP": new LdNum(ProtocolType.IDP),
			"IPPROTO_RAW": new LdNum(ProtocolType.RAW),
			"IPPROTO_IPV6": new LdNum(ProtocolType.IPV6),

			"SHUT_RD": new LdNum(SocketShutdown.SEND),
			"SHUT_WR": new LdNum(SocketShutdown.RECEIVE),
			"SHUT_RDWR": new LdNum(SocketShutdown.BOTH),

			"SOL_ICMP": new LdNum(SocketOptionLevel.ICMP),
			"SOL_RAW": new LdNum(SocketOptionLevel.RAW),
			"SOL_SOCKET": new LdNum(SocketOptionLevel.SOCKET),
			"SOL_GGP": new LdNum(SocketOptionLevel.GGP),
			"SOL_IP": new LdNum(SocketOptionLevel.IP),
			"SOL_PUP": new LdNum(SocketOptionLevel.PUP),
			"SOL_IPV6": new LdNum(SocketOptionLevel.IPV6),
			"SOL_IGMP": new LdNum(SocketOptionLevel.IGMP),
			"SOL_UDP": new LdNum(SocketOptionLevel.UDP),
			"SOL_TCP": new LdNum(SocketOptionLevel.TCP),
			"SOL_IDP": new LdNum(SocketOptionLevel.IDP),

			"SO_ACCEPTCONN": new LdNum(SocketOption.ACCEPTCONN),
			"SO_BROADCAST": new LdNum(SocketOption.BROADCAST),
			"SO_DEBUG": new LdNum(SocketOption.DEBUG),
			"SO_DONTROUTE": new LdNum(SocketOption.DONTROUTE),
			"SO_ERROR": new LdNum(SocketOption.ERROR),
			"SO_IPV6_JOIN_GROUP": new LdNum(SocketOption.IPV6_JOIN_GROUP),
			"SO_IPV6_LEAVE_GROUP": new LdNum(SocketOption.IPV6_LEAVE_GROUP),
			"SO_IPV6_MULTICAST_HOPS": new LdNum(SocketOption.IPV6_MULTICAST_HOPS),
			"SO_IPV6_MULTICAST_IF": new LdNum(SocketOption.IPV6_MULTICAST_IF),
			"SO_IPV6_MULTICAST_LOOP": new LdNum(SocketOption.IPV6_MULTICAST_LOOP),
			"SO_IPV6_UNICAST_HOPS": new LdNum(SocketOption.IPV6_UNICAST_HOPS),
			"SO_IPV6_V6ONLY": new LdNum(SocketOption.IPV6_V6ONLY),
			"SO_KEEPALIVE": new LdNum(SocketOption.KEEPALIVE),
			"SO_LINGER": new LdNum(SocketOption.LINGER),
			"SO_OOBINLINE": new LdNum(SocketOption.OOBINLINE),
			"SO_RCVBUF": new LdNum(SocketOption.RCVBUF),
			"SO_RCVLOWAT": new LdNum(SocketOption.RCVLOWAT),
			"SO_RCVTIMEO": new LdNum(SocketOption.RCVTIMEO),
			"SO_REUSEADDR": new LdNum(SocketOption.REUSEADDR),
			"SO_SNDBUF": new LdNum(SocketOption.SNDBUF),
			"SO_SNDLOWAT": new LdNum(SocketOption.SNDLOWAT),
			"SO_SNDTIMEO": new LdNum(SocketOption.SNDTIMEO),
			"SO_TCP_NODELAY": new LdNum(SocketOption.TCP_NODELAY),
			"SO_TYPE": new LdNum(SocketOption.TYPE),
		];
	}

	override LdOBJECT[string] __props__(){ return props; }

	override string __str__(){ return "socket (native module)"; }
}


class GetAdrrInfo: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, HEAP* mem=null){
    	LdOBJECT[] info;

    	auto addr = getAddress(args[0].__str__);
    	auto op_len = addr.length/2;

    	if(op_len == 1)
    		return new LdStr(addr[0].toAddrString);

    	return new LdStr(addr[op_len-1].toAddrString);
    }

    override string __str__() { return "socket.getaddrinfo (method)"; }
}


class GetHostByName: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, HEAP* mem=null){
    	auto addr = getAddress(args[0].__str__);

    	if(addr.length) {
	    	auto op_len = addr.length/2;

	    	if(op_len == 1)
	    		return new LdStr(addr[0].toAddrString);

	    	return new LdStr(addr[op_len-1].toAddrString);
	    }

	    return RETURN.A;
    }

    override string __str__() { return "socket.gethostbyname (method)"; }
}

class GetHostByAddr: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, HEAP* mem=null){
    	InternetHost ih = new InternetHost;
		ih.getHostByAddr(args[0].__str__);

		return new LdStr(ih.name);
    }

    override string __str__() { return "socket.gethostbyaddr (method)"; }
}



class new_socket: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, HEAP* mem=null){
        if (args.length == 2)
        	return new _socket_obj(new Socket( cast(AddressFamily)args[0].__num__,
        								   cast(SocketType)args[1].__num__) );

        else if (args.length > 2)
        	return new _socket_obj( new Socket( cast(AddressFamily)args[0].__num__,
        						            cast(SocketType)args[1].__num__,
        						            cast(ProtocolType)args[2].__num__ ) );

        else if (args.length == 1)
        	if (toLower(args[0].__str__) == "udp")
        		return new _socket_obj(new UdpSocket());
        
        return new _socket_obj(new TcpSocket());
    }

    override string __str__() { return "socket.Socket (object)";}
}


class _socket_obj: LdOBJECT
{
    HEAP props;
    Socket socket;

    this(Socket socket){
        this.socket = socket;
        this.socket.blocking = true;

        this.props = [
        	"isalive": new _IsAlive(socket),
        	"blocked": new _blocked(socket),

        	"bind": new _bind(socket),
        	"connect": new _connect(socket),

        	"listen": new _listen(socket),
        	"setblocking": new _setblocking(socket),

        	"accept": new _accept(socket),
        	"send": new _send(socket),
        	"sendto": new _sendto(socket),
        	"recv": new _recv(socket),

        	"setsockopt": new _setsockopt(socket),

        	"shutdown": new _shutdown(socket),
        	"close": new _close(socket),

        	"hostname": new LdStr(socket.hostName),
        	"addr_family": new LdNum(cast(double)socket.addressFamily),
        ];
    }
   	
   	override LdOBJECT[string] __props__(){ return props; }

	override string __str__(){ return format("socket.Socket (object af: %s)", socket.addressFamily); }
}


class _bind: LdOBJECT
{
    Socket socket;
    this(Socket socket){ this.socket = socket; }

    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, HEAP* mem=null){
        if (args.length > 1)
            socket.bind(new InternetAddress(args[0].__str__, cast(ushort)args[1].__num__));
       	else
        	throw new Exception("socket.bind takes a 'host-name' and 'port-number'.");

        return RETURN.A;
    }

    override string __str__() { return "bind (Socket.socket method)"; }
}


class _connect: LdOBJECT
{
    Socket socket;
    this(Socket socket){ this.socket = socket; }

    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, HEAP* mem=null){
        if (args.length > 1)
            this.socket.connect(new InternetAddress(args[0].__str__, cast(ushort)args[1].__num__));
       	else
        	throw new Exception("socket.connect takes a 'host-name' and 'port-number'.");

        return RETURN.A;
    }

    override string __str__() { return "connect (Socket.socket method)"; }
}


class _listen: LdOBJECT
{
    Socket socket;
    this(Socket socket){ this.socket = socket; }

    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, HEAP* mem=null){
        socket.listen(cast(int)args[0].__num__);
        return RETURN.A;
    }

    override string __str__() { return "listen (Socket.socket method)"; }
}


class _setblocking: LdOBJECT
{
    Socket socket;
    this(Socket socket){ this.socket = socket; }

    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, HEAP* mem=null){
        if(args[0].__true__)
            socket.blocking = true;
        else
            socket.blocking = false;

        return RETURN.A;
    }

    override string __str__() { return "setblocking (Socket.socket method)"; }
}



class _accept: LdOBJECT
{
    Socket socket;
    this(Socket socket){ this.socket = socket; }

    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, HEAP* mem=null){
        return new _socket_obj(socket.accept());
    }

    override string __str__() { return "accept (Socket.socket method)"; }
}


class _send: LdOBJECT
{
    Socket socket;
    this(Socket socket){ this.socket = socket; }

    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, HEAP* mem=null){
        socket.send(args[0].__chars__);
        return RETURN.A;
    }

    override string __str__() { return "send (Socket.socket method)"; }
}


class _sendto: LdOBJECT
{
    Socket socket;
    this(Socket socket){ this.socket = socket; }

    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, HEAP* mem=null){
        socket.sendTo(args[0].__chars__);
        return new LdNone();
    }

    override string __str__() { return "sendto (Socket.socket method)"; }
}


class _recv: LdOBJECT
{
    Socket socket;
    char[64000] buffer;

    this(Socket socket){
    	this.buffer = buffer;
    	this.socket = socket;
    }

    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, HEAP* mem=null){
        auto data = socket.receive(buffer);

        if(data == -1)
        	return new LdChr([]);

        else if (data == 0)
        	throw new Exception("socketError: remote side closed connection.");

        return new LdChr(buffer[0 .. data]);
    }

    override string __str__() { return "recv (Socket.socket method)"; }
}


class _shutdown: LdOBJECT
{
    Socket socket;
    this(Socket socket){ this.socket = socket; }

    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, HEAP* mem=null){
        if (args.length)
            socket.shutdown(cast(SocketShutdown)args[0].__num__); 
        else
        	socket.shutdown(SocketShutdown.BOTH);

        return RETURN.A;
    }

    override string __str__() { return "shutdown (Socket.socket method)"; }
}


class _close: LdOBJECT
{
    Socket socket;
    this(Socket socket){ this.socket = socket; }

    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, HEAP* mem=null){
        socket.close();
        return RETURN.A;
    }

    override string __str__() { return "close (Socket.socket method)"; }
}


class _IsAlive: LdOBJECT
{
    Socket socket;
    this(Socket socket){ this.socket = socket; }

    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, HEAP* mem=null){
        if (socket.isAlive())
            return RETURN.B;

        return RETURN.C;
    }

    override string __str__() { return "IsAlive (Socket.socket method)"; }
}


class _blocked: LdOBJECT
{
    Socket socket;
    this(Socket socket){ this.socket = socket; }

    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, HEAP* mem=null){
        if (socket.blocking)
            return RETURN.B;

        return RETURN.C;
    }

    override string __str__() { return "blocked (Socket.socket method)"; }
}


class _setsockopt: LdOBJECT
{
    Socket socket;
    this(Socket socket){ this.socket = socket; }

    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, HEAP* mem=null){
    	socket.setOption(
    		cast(SocketOptionLevel)args[0].__num__,
    		cast(SocketOption)args[1].__num__,
    		cast(int)args[2].__num__
    	);

        return RETURN.A;
    }

    override string __str__() { return "setsockopt (Socket.socket method)"; }
}

