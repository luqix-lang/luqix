import std.stdio;

import std.file: readText, exists, isFile, thisExePath;
import std.path: absolutePath;

import std.algorithm.searching: canFind, endsWith;
import std.algorithm.mutation: remove;

import std.string: strip;
import std.array: replicate;

import LdParser, LdLexer, LdNode, LdBytes, LdIntermediate, LdExec;
import LdObject, LdString;

import importlib: __setImp__, _StartHeap;


string _Console_Input(){
	string code, a;

	write("> ");
	a = strip(readln());

	if(a.endsWith("{")) {
		short yet = 1;
		while (yet){
			code ~= a~'\n';

			write("...", replicate("    ", yet));
			a = strip(readln());

			if(a.endsWith("{"))
				yet++;

			else if (a.endsWith("}")) {
				yet--;

				if(!yet)
					code ~= a;
			}
		}
		return code;
	}
	return a;
}


int _console(){
	string code;
	
	auto _Bage = _StartHeap.dup;
	LdOBJECT[string]* _Heap = &(_Bage);

	TOKEN[] tokens;
	LdByte[] bcode;

	writef(" Luqix 1.00.1 (official July 26 2023)\n check https://luqix-lang.github.io\n\n");

	while (true)
	{
		try{
			code = _Console_Input();
			
			if(code.length) {
				tokens = new _Lex(code).TOKENS;
				bcode = new _GenInter(new _Parse(tokens, "__stdin__").ast).bytez;

				_Heap = new _Interpreter(bcode, _Heap).heap;
			}
		} 
		catch (Exception e)
			writeln("Error: ", e.msg);
	}

	return 0;
}

int _start(string[] args){
	string filo = absolutePath(args[0]);

	if (exists(filo) && isFile(filo)) {

		string code = readText(filo);
		TOKEN[] tokens = new _Lex(code).TOKENS; Node[] tree = new _Parse(tokens, filo).ast;

		LdByte[] bcode = new _GenInter(tree).bytez;

		auto scope_ = _StartHeap.dup;
		scope_["-file-"] = new LdStr(filo);

		try
			new _Interpreter(bcode, &scope_);
		catch (Exception e) {
			writeln(e.msg);
			
			foreach(i; *(scope_["-traceback-"].__ptr__))
				writefln("    at %s (%s)", i.__getProp__("name").__str__,
										  i.__getProp__("file").__str__
				);
		}

	} else if(canFind(args, "-v"))
		writeln("luqix 0.10.1");

	else if(canFind(args, "-e"))
		writeln(thisExePath);

	else if(canFind(args, "-h"))
	{
		writeln("luqix [0.10.3]
...
-e     : shows the luqix interpreter executable path
-h     : returns this help message
-v     : prints the luqix version installed on your pc");
	}
	else
		writef("luqix: Error '%s': [Errno 2] No such file\n", filo);

	return 0;
}


int main(string[] args)
{
	args = args.remove(0);
	
	LdBytes._AUTO_VARS = __setImp__(args);

	if(!args.length)
		return _console();

	_start(args);

	return 0;
}
