module lLocals;

import std.stdio;

import std.string: chomp;
import std.algorithm.iteration: each;

import std.algorithm.searching: find;
import std.format: format;

import core.stdc.stdio: printf;
import core.stdc.stdlib: exit;

import LdObject;

// included to locals
import lList: oList;
import lDict: oDict;

import LdString: oStr;
import LdChar: oBytes;

alias LdOBJECT[string] HEAP; 


class oLocals: LdOBJECT
{
	LdOBJECT[string] props;

	this(LdOBJECT[string] props){
		this.props = props;
	}

	override LdOBJECT[string] __props__(){ return props; }

	override string __str__(){ return "locals (native module)"; }
}


static LdOBJECT[string] __locals_props__(){
	return [
			"print": new _Print(),
			"prompt": new _Prompt(),

			"super": new _Super(),
			"Exception": new _Exception(),

			"len": new _Len(),
			"attr": new _Attr(),

			"type": new _Type(),
			"exit": new _Exit(),

			"eval": new _Eval(),
			"exec": new _Exec(),
			"require": new _Require(),

			"getattr": new _Getattr(),
			"setattr": new _Setattr(),
			"delattr": new _Delattr(),

			"str": new oStr(),
			"list": new oList(),
			"dict": new oDict(),
			"bytes": new oBytes(),
		];
}


static void cprints(string i) {
	printf("%.*s ", cast(int)i.length, i.ptr);
}

class _Print: LdOBJECT
{
	override LdOBJECT opCall(LdOBJECT[] args, uint line=0, HEAP* mem=null){
		args.each!(n => cprints(n.__str__));
		printf("\n");

		return RETURN.A;
	}

	override string __str__(){ return "locals.print (method)"; }
}


// importing core modules

import lTime: oTime;
import lBase64: oBase64;

import lMath: oMath;
import lSocket: oSocket;
import lFile: oFile;

import lJson: oJson;
import lPath: oPath;

import lParallelism: oParallel;

import lNumber: oNumber;

import lDtypes: oDtypes;
import lRandom: oRandom;

import lRegex: oRegex;
import lProcess: oSubProcess;

import Os: oS;
import Websock: oWebsock;

import lUrl: oUrl;
import lThread: oThread;


const string[] _Core_Lib = ["base64", "locals", "dtypes", "file", "json", "math", "number", "os", "parallelism", "path", "process", "random", "regex", "socket", "sys", "sqlite3", "thread", "time", "url", "websock"];

LdOBJECT[string] Required_Lib;


LdOBJECT import_core_library(string X){
	switch (X) {
		case "base64":
			return new oBase64();
		case "dtypes":
			return new oDtypes();
		case "file":
			return new oFile();
		case "json":
			return new oJson();
		case "path":
			return new oPath();
		case "regex":
			return new oRegex();
		case "random":
			return new oRandom();
		case "socket":
			return new oSocket();
		case "number":
			return new oNumber();
		case "process":
			return new oSubProcess();
		case "thread":
			return new oThread();
		case "parallelism":
			return new oParallel();
		case "sqlite3":
			return RETURN.A;
			//return new oSqlite3();
		case "time":
			return new oTime();
		case "os":
			return new oS();
		case "url":
			return new oUrl();
		case "websock":
			return new oWebsock();
		default:
			return new oMath();
	}
}


class _Require: LdOBJECT
{
	override LdOBJECT opCall(LdOBJECT[] args, uint line=0, HEAP* mem=null){
		string y = args[0].__str__;

		if (y in Required_Lib)
			return Required_Lib[y];

		if (find(_Core_Lib, y).length) {
			auto x = import_core_library(y);
			Required_Lib[y] = x;

			return x;
		}

		throw new Exception(format("RequireError: core module '%s' not found", y));

		return RETURN.A;
	}

	override string __str__(){ return "locals.require (method)"; }
}


class _Prompt: LdOBJECT
{
	override LdOBJECT opCall(LdOBJECT[] args, uint line=0, HEAP* mem=null){
		if (args.length)
			write(args[0].__str__);

		return new LdStr(chomp(readln()));
	}

	override string __str__(){ return "locals.prompt (method)"; }
}


class _Super: LdOBJECT 
{
	override LdOBJECT opCall(LdOBJECT[] args, uint line=0, HEAP* mem=null){
		return args[0].__super__(args[1]);
	}

	override string __str__(){ return "locals.super (method)"; }
}


class _Exception: LdOBJECT 
{
	string _file;
	int _line;
	string _type;

	this(){
		this._file = "";
		int _line = 0;
		string _type = "UknownError";
	}

	override LdOBJECT opCall(LdOBJECT[] args, uint line=0, HEAP* mem=null){
		LdOBJECT[string] formal = ["msg":new LdStr(_file), "type":new LdStr(_type), "line":new LdNum(_line)];

		if (args.length) {
			foreach(k,l; args[0].__props__)
				formal[k] = l;
		}
		
		return new LdEnum("Error", formal);
	}

	override string __str__(){ return "locals.Exception (method)"; }
}


class _Len: LdOBJECT 
{
	override LdOBJECT opCall(LdOBJECT[] args, uint line=0, HEAP* mem=null){
		return new LdNum(args[0].__length__);
	}

	override string __str__(){ return "locals.len (method)"; } 
}

class _Type: LdOBJECT 
{
	override LdOBJECT opCall(LdOBJECT[] args, uint line=0, HEAP* mem=null){
		return new LdStr(args[0].__type__);
	}

	override string __str__(){ return "locals.type (method)"; } 
}


import std.algorithm.comparison: cmp;

string[] sort_strings(string[] n) {
    string temp;

    for(size_t i = 0; i < (n.length-1); i++){
        size_t n_min = i;

        for(size_t j = i + 1; j < n.length; j++)
            if (cmp(n[j], n[n_min]) < 0){
                n_min = j;
            }

        if (n_min != i) {
            temp = n[i];
            n[i] = n[n_min];
            n[n_min] = temp;
        }
    }
    return n;
}

class _Attr: LdOBJECT 
{
	override LdOBJECT opCall(LdOBJECT[] args, uint line=0, HEAP* mem=null){
		LdOBJECT[] arr;
		(sort_strings(args[0].__props__.keys())).each!(i => arr ~= new LdStr(i));
		return new LdArr(arr);
	}

	override string __str__(){ return "locals.attr (method)"; } 
}


class _Getattr: LdOBJECT 
{
	override LdOBJECT opCall(LdOBJECT[] args, uint line=0, HEAP* mem=null){
		return args[0].__getProp__(args[1].__str__);
	}

	override string __str__(){ return "locals.getattr (method)"; } 
}

class _Setattr: LdOBJECT 
{
	override LdOBJECT opCall(LdOBJECT[] args, uint line=0, HEAP* mem=null){
		args[0].__setProp__(args[1].__str__, args[2]);
		return RETURN.A;
	}

	override string __str__(){ return "locals.setattr (method)"; } 
}

class _Delattr: LdOBJECT 
{
	override LdOBJECT opCall(LdOBJECT[] args, uint line=0, HEAP* mem=null){
		args[0].__deleteProp__(args[1].__str__);
		return RETURN.A;
	}

	override string __str__(){ return "locals.delattr (method)"; } 
}


class _Exit: LdOBJECT 
{
	override LdOBJECT opCall(LdOBJECT[] args, uint line=0, HEAP* mem=null){
		exit(0);
		return RETURN.A;
	}

	override string __str__(){ return "locals.exit (method)"; } 
}


import LdParser, LdNode, LdBytes, LdIntermediate, LdExec;
import LdLexer: _Lex;


TOKEN[] man_tokens(string code) {
	TOKEN[] toks;

	TOKEN A = {"#eval", "ID", 0, 1, 1}; toks ~= A;
	TOKEN B = {"=", "=", 0, 1, 1}; toks ~= B;

	return (toks ~ new _Lex(code).TOKENS);
}

class _Eval: LdOBJECT
{
	override LdOBJECT opCall(LdOBJECT[] args, uint line=0, HEAP* mem=null) {
		LdByte[] bin = new _GenInter ( new _Parse( man_tokens(args[0].__str__), "eval.io" ).ast ).bytez;

		return (*(new _Interpreter(bin, mem).heap))["#eval"];
	}

	override string __str__(){ return "locals.eval (method)"; }
}

class _Exec: LdOBJECT
{
	override LdOBJECT opCall(LdOBJECT[] args, uint line=0, HEAP* mem=null) {
		LdByte[] bin = new _GenInter ( new _Parse( new _Lex(args[0].__str__).TOKENS, "eval.io" ).ast ).bytez;
		new _Interpreter(bin, mem);

		return RETURN.A;
	}

	override string __str__(){ return "locals.exec (method)"; }
}

