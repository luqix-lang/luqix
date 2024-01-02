import std.stdio;

import std.path: absolutePath;
import std.algorithm.mutation: remove;
import std.file: readText, exists, isFile;

import LdObject, LdParser, LdLexer, LdNode, LdBytes, LdIntermediate, LdExec;

import importlib: __setImp__, _StartHeap;
import console_interface: start_cmdline, cmd_executor;


void _start_interpreter(string[] args) {
	string baseFile = absolutePath(args[0]);

	if (exists(baseFile) && isFile(baseFile)) {
		string code = readText(baseFile);

		auto toks = new _Lex(code).TOKENS;
		auto absTree = new _Parse(toks, baseFile).ast;
		auto lqBytecode = new _GenInter(absTree).bytez;

		auto _Heap = _StartHeap.dup;
		_Heap["-file-"] = new LdStr(baseFile);

		try
			new _Interpreter(lqBytecode, &_Heap);
		catch (Exception e) {
			writeln(e.msg);
			
			foreach(i; *(_Heap["-traceback-"].__ptr__))
				writefln("    at %s (%s)", i.__getProp__("name").__str__, i.__getProp__("file").__str__ );
		}

	} else
		cmd_executor(args, baseFile);
}


int main(string[] args) {
	args = args.remove(0);
	// setting starting variables
	__setImp__(args);

	if(!args.length)
		start_cmdline();
	else
		_start_interpreter(args);
	
	return 0;
}
