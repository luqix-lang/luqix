module Websock;

import std.stdio;
import std.socket;
import std.conv;
import std.digest.sha;
import std.base64;
import std.regex;
import std.bitmanip;
import std.random;
import std.array;
import std.format: format;

import std.path: buildPath;
import std.file: write, exists, isDir;

import core.thread.osthread: Thread;
import core.time: dur;
import core.stdc.time;

import LdObject;
import lJson: _Parse;

alias LdOBJECT[string] HEAP;

class oWebsock: LdOBJECT {
	HEAP props;

	this(){
		this.props = [ "WebsocketServer": new _WebsocketServer(),];
	}

	override string __type__(){
		return "websocket module";
	}

	override LdOBJECT[string] __props__(){ return props; }
	override string __str__(){ return "websocket (native module)"; }
}


class _WebsocketServer: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, HEAP* mem=null){
    	return new _Websocket(args[0].__str__, cast(ushort)args[1].__num__);
    }
    override string __str__() { return "websocket.WebsocketServer (type)";}
}


enum BUFF_SIZE = 64000;
enum MAX_MSGLEN = 65535;


class _Websocket: LdOBJECT {
	HEAP props;
	Socket ws, client;

	LdOBJECT[] onopen, onmessage;
	HEAP*[] onmessage_file;
	uint[] onmessage_line;

	this(string hostname, ushort port){
		this.client = client;

		version (all) {
			this.ws = new TcpSocket();
			this.ws.bind(new InternetAddress(hostname, port));

			this.ws.blocking = true;
			this.ws.listen(1);
		}

		this.onopen = onopen;

		version(all){
			this.onmessage = onmessage;
			this.onmessage_file = onmessage_file;
			this.onmessage_line = onmessage_line;
		}

		this.props = [
			"hostname": new LdStr(hostname),
			"port": new LdNum(port),

			"onopen": new _Onopen(this),
			"onmessage": new _Onmessage(this),

			"send": new _Send(this),
			"start": new _Start(this),
		];
	}

	void event_listener(){
		while (true) {
			char[BUFF_SIZE] buf;
			auto len = this.client.receive(buf);

			if (len > 0)
				on_message(buf[0..len]);
			else {
				writeln("ERROR: Maybe frontend disconnected or encounted an error.");
				break;
			}
		}

		this.client.shutdown(SocketShutdown.BOTH);
		this.client.close();

		this.ws.shutdown(SocketShutdown.BOTH);
		this.ws.close();
	}

	void on_message(char[] data){
		ubyte[] bytes = cast(ubyte[])data;

		bool fin = (bytes[0] & 0b10000000) != 0;
		bool mask = (bytes[1] & 0b10000000) != 0;

	    int opcode = bytes[0] & 0b00001111;
	    int offset = 2;

	    size_t msglen = bytes[1] & 0b01111111;

	    if (msglen == 126) {
	    	msglen = bytes.peek!ushort(2);
	        offset = 4;
	    
	    } else if (msglen == 127) {
	        msglen = bytes.peek!size_t(2);
	        offset = 10;
	    }

	    // to text
	    ubyte[] decoded = new ubyte[msglen];
        ubyte[] masks = [bytes[offset], bytes[offset + 1], bytes[offset + 2], bytes[offset + 3]];
        offset += 4;

        for (size_t i = 0; i < msglen; ++i)
            decoded[i] = cast(ubyte)(bytes[offset + i] ^ masks[i % 4]);

        LdOBJECT[1] ret = [new LdEnum("ws-event", ["data": new LdChr(cast(char[])decoded)])];

        // executing callback onmessage functions
        for(size_t i =0; i < onmessage.length; i++){
        	onmessage[i](ret, onmessage_line[i], onmessage_file[i]);
    	}
    }

	override LdOBJECT[string] __props__(){
		return props;
	}

	override string __str__(){ return "websocket.Open (object)"; }
}


Socket _Acceptor(Socket ws){

	// handle connected address / host
	Socket client = ws.accept();

	while (true) {
		char[] msg;
		char[BUFF_SIZE] buf;

		auto data = client.receive(buf);
		msg = buf[0..data];

		auto sec = match(cast(string)msg, "Sec-WebSocket-Key: (.*)");
	    string swka;
	    
	    bool wbSocket = false;

		foreach(i; sec){
	    	if(i.length > 1){
	    		wbSocket = true;
	    		swka = i[1];
	    	}
	    	break;
	    }

	    if (wbSocket){
		    swka ~= "258EAFA5-E914-47DA-95CA-C5AB0DC85B11";
		    
		    ubyte[20] swkaSha1 = sha1Of(swka);
		    string swkaSha1Base64 = Base64.encode(swkaSha1);

		    string res = (
		        "HTTP/1.1 101 Switching Protocols\r\n" ~
		        "Connection: Upgrade\r\n" ~
		        "Upgrade: websocket\r\n" ~
		        "Sec-WebSocket-Accept: " ~ swkaSha1Base64 ~ 
		        "\r\n\r\n"
		    );

			client.send(cast(char[])res);				
			break;
		}
	}

	return client;
}


class _Send: LdOBJECT {
	_Websocket ws;
	Socket client;

	this (_Websocket ws){
		this.ws = ws;
	}

	override LdOBJECT opCall(LdOBJECT[] args, uint line=0, HEAP* mem=null){
		char[] data = args[0].__chars__;
		
		char[] op = [129];
	    auto len = appender!(const ubyte[])();

        if (data.length < 126)
        	op ~= cast(ubyte)data.length;

        else if (data.length < MAX_MSGLEN+1) {
			op ~= 126;
			len.append!ushort(cast(ushort)data.length);

        } else {
        	op ~= 127;
        	len.append!ulong(data.length);
        }

        op ~= cast(char[])len.data ~ data;
        this.ws.client.send(op);

		return RETURN.A;
	}

	override string __str__(){ return "send (websocket.Open method)"; }
}

class _Onopen: LdOBJECT {
	_Websocket ws;

	this (_Websocket ws){
		this.ws = ws;
	}

	override LdOBJECT opCall(LdOBJECT[] args, uint line=0, HEAP* mem=null){
		ws.onopen ~= args[0];
		return RETURN.A;
	}

	override string __str__(){ return "onopen (websocket.Open method)"; }
}

class _Onmessage: LdOBJECT {
	_Websocket ws;

	this (_Websocket ws){
		this.ws = ws;
	}

	override LdOBJECT opCall(LdOBJECT[] args, uint line=0, HEAP* mem=null){
		ws.onmessage ~= args[0];
		ws.onmessage_file ~= mem;
		ws.onmessage_line ~= line;

		return RETURN.A;
	}

	override string __str__(){ return "onmessage (websocket.Open method)"; }
}

class _Start: LdOBJECT {
	_Websocket ws;

	this (_Websocket ws){
		this.ws = ws;
	}

	override LdOBJECT opCall(LdOBJECT[] args, uint line=0, HEAP* mem=null){
		version (all) {
			this.ws.client = _Acceptor(this.ws.ws);

			// executing callback onopen functions
			foreach(LdOBJECT i; ws.onopen)
				i([], line, mem);
		}

		this.ws.event_listener();
		return RETURN.A;
	}

	override string __str__(){ return "start (websocket.Open method)"; }
}
