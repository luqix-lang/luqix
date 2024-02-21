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

			"getAddressInfo": new GetAdrrInfo(),
			"getHostByName": new GetHostByName(),
			"getHostByAddress": new GetHostByAddr(),
		];
	}

	override LdOBJECT[string] __props__(){ return props; }

    override string __type__(){ return "native module";}

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

    override string __str__() { return "socket.getAddressInfo (method)"; }
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

    override string __str__() { return "socket.getHostByName (method)"; }
}

class GetHostByAddr: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, HEAP* mem=null){
    	InternetHost ih = new InternetHost;
		ih.getHostByAddr(args[0].__str__);

		return new LdStr(ih.name);
    }

    override string __str__() { return "socket.getHostByAddress (method)"; }
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
        	"alive": new _IsAlive(socket),
        	"blocked": new _blocked(socket),

        	"bind": new _bind(socket),
        	"connect": new _connect(socket),

        	"listen": new _listen(socket),
        	"setBlocking": new _setblocking(socket),

        	"accept": new _accept(socket),
        	"send": new _send(socket),
        	"sendTo": new _sendto(socket),
        	"recieve": new _recv(socket),

        	"setSocketOption": new _setsockopt(socket),

        	"shutDown": new _shutdown(socket),
        	"close": new _close(socket),

        	"hostname": new LdStr(socket.hostName),
        	"addressFamily": new LdNum(cast(double)socket.addressFamily),
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

    override string __str__() { return "socket.Socket.bind (method)"; }
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

    override string __str__() { return "socket.Socket.connect (method)"; }
}


class _listen: LdOBJECT
{
    Socket socket;
    this(Socket socket){ this.socket = socket; }

    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, HEAP* mem=null){
        socket.listen(cast(int)args[0].__num__);
        return RETURN.A;
    }

    override string __str__() { return "socket.Socket.listen (method)"; }
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

    override string __str__() { return "socket.Socket.setBlocking (method)"; }
}



class _accept: LdOBJECT
{
    Socket socket;
    this(Socket socket){ this.socket = socket; }

    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, HEAP* mem=null){
        return new _socket_obj(socket.accept());
    }

    override string __str__() { return "socket.Socket.accept (method)"; }
}


class _send: LdOBJECT
{
    Socket socket;
    this(Socket socket){ this.socket = socket; }

    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, HEAP* mem=null){
        socket.send(args[0].__chars__);
        return RETURN.A;
    }

    override string __str__() { return "socket.Socket.send (method)"; }
}


class _sendto: LdOBJECT
{
    Socket socket;
    this(Socket socket){ this.socket = socket; }

    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, HEAP* mem=null){
        socket.sendTo(args[0].__chars__);
        return new LdNone();
    }

    override string __str__() { return "socket.Socket.sendTo (method)"; }
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

    override string __str__() { return "socket.Socket.recieve (method)"; }
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

    override string __str__() { return "socket.Socket.shutDown (method)"; }
}


class _close: LdOBJECT
{
    Socket socket;
    this(Socket socket){ this.socket = socket; }

    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, HEAP* mem=null){
        socket.close();
        return RETURN.A;
    }

    override string __str__() { return "socket.Socket.close (method)"; }
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

    override string __str__() { return "socket.Socket.alive (method)"; }
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

    override string __str__() { return "socket.Socket.blocked (method)"; }
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

    override string __str__() { return "socket.Socket.setSocketOption (method)"; }
}

