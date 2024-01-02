module console_interface;

import std.stdio;
import std.array: replicate, join;

import std.string: chomp;

import std.format: format;
import std.algorithm.iteration: map;

import std.file: thisExePath;
import std.algorithm.searching:canFind, endsWith;

import LdParser, LdLexer, LdNode, LdBytes, LdIntermediate, LdExec, LdObject;
import importlib: _StartHeap;

import std.string: strip;


string color_dict(LdOBJECT val){
	string view = "{";

	foreach(k, v; val.__hash__)
		view ~= format(" %s: %s,", k, color_console(v));

	return chomp(view, ",") ~ " }";
}

string color_console(LdOBJECT val){
	string esc;

	switch (val.__type__) {
		case "string":
			return format("\033[0;32m%s\033[0m", val.__json__);

		case "number": case "boolean":
			return format("\033[0;33m%s\033[0m", val.__str__);

		case "function":
			return format("\033[0;36m%s\033[0m", val.__str__);

		case "list":
			return "[ " ~ (val.__array__).map!(n => color_console(n)).join(", ") ~ " ]";

		case "dict":
			return color_dict(val);

		default:
			esc = val.__str__;
	}

	return esc;
}

Node[] retAbsTree(Node[] tree) {
	if ((tree.length == 1) && (canFind([1,2,3,4,5,7,8,9,26,27,31,32,33,37], tree[0].type)))
		return [new VarNode("-console-", tree[0])];

	return tree;
}

string parse_cmd_code() {
	write("> ");
	string code = strip(readln());

	if(code.endsWith("{")) {
		short ln_incre = 1;

		while (ln_incre) {
			write("...", replicate(" ", ln_incre));
			code ~= '\n' ~ strip(readln());

			if(code.endsWith("{"))
				ln_incre++;
			else if (code.endsWith("}"))
				ln_incre--;
		}
	}
	return code;
}


void start_cmdline(){
	auto store = _StartHeap.dup;
	LdOBJECT[string]* _Heap = &(store);

	(*_Heap)["-file-"] = new LdStr("stdin");

	writeln("Hey, am luqix v0.9.2.\nAt start, Type '--help' for more information");
	string code;

	while (true) {
		try {
			code = parse_cmd_code();
			
			if(code.length) {
				auto toks = new _Lex(code).TOKENS;
				auto absTree = retAbsTree(new _Parse(toks, "__stdin__").ast);
				auto lqBytecode = new _GenInter(absTree).bytez;

				_Heap = new _Interpreter(lqBytecode, _Heap).heap;

				if ("-console-" in *_Heap) {
					auto val = (*_Heap)["-console-"];

					if (val.__type__ != "null") {
						version (Windows)
							writeln(val.__str__);
						else {
							if(val.__type__ != "none")
								writeln(color_console(val));
						}
					}

					(*_Heap).remove("-console-");
				}
			}
		} 
		catch (Exception e)
			writeln("\033[1;31mError\033[0m: ", e.msg);
	}
}


void cmd_executor(string[] args, string baseFile){
	 if(canFind(args, "--version"))
		writeln("luqix 0.9.2");

	else if(canFind(args, "--exec"))
		writeln(thisExePath);

	else if(canFind(args, "--help")) {
		writeln("luqix [0.9.2]
..
--exec     Returns luqix interpreter executable
--help     Returns this help message
--version  Returns version installed" );

	} else
		writef("luqix: \033[1;31mError\033[0m '%s': [Errno 2] No such file\n", baseFile);
}

