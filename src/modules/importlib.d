module importlib;

import std.format: format;
import std.stdio: writeln;

import std.algorithm.searching: endsWith, startsWith, find;
import std.algorithm.iteration: map;
import std.algorithm.mutation: remove;

import std.array: array, split, replace;
import std.file: exists, isFile, isDir, readText, dirEntries, SpanMode;

import std.path: buildPath, absolutePath, stripExtension, baseName, dirSeparator;
import LdParser, LdLexer, LdNode, LdBytes, LdIntermediate, LdExec;

import LdObject;
import lLocals, lSys: oSys;



alias LdOBJECT[string] HEAP;
HEAP imported_modules, _runtimeModules;

LdModule[][string] Circular;
LdOBJECT[string] _StartHeap;


LdOBJECT[string] __setImp__(string[] args) {
	_StartHeap = [
		"#rtd": new LdTrue(),
		"#rt": new LdNone(),
		"#bk": new LdTrue(),
		"-traceback-": new LdArr([]),
	];

	_runtimeModules = [ "": new LdStr("") ];

	// enter in runtimeModule to modules_path
	oSys sys = new oSys(args, new LdHsh(_runtimeModules));
	auto _locals_functions = __locals_props__;

	lLocals.Required_Lib = [
				"sys": sys,
				"locals": new oLocals(_locals_functions),
			];

	// setting modules to imported_modules
	sys.__setProp__("modules", new LdHsh(imported_modules));

	return [

		"attr": _locals_functions["attr"],
		"type": _locals_functions["type"],
		
		"print": _locals_functions["print"],
		"prompt": _locals_functions["prompt"],
		
		"exit": _locals_functions["exit"],
		"super": _locals_functions["super"],

		"Exception": _locals_functions["Exception"],

		"len": _locals_functions["len"],
		"next": _locals_functions["next"],

		"importc": _locals_functions["importc"],

		"getattr": _locals_functions["getattr"],
		"setattr": _locals_functions["setattr"],
		"delattr": _locals_functions["delattr"],

		"iter": _locals_functions["iter"],				
		"StopIterator": _locals_functions["StopIterator"],
	];
}


class LdModule: LdOBJECT {
	string name, _path;
	LdOBJECT[string] props;
	
	this(string name, string _path, LdOBJECT[string] props) {
		this.name = baseName(name);
		this.props = props;
		this._path = _path;
	}

	override LdOBJECT[string] __props__(){ return props; }

	override string __str__(){ return format("%s (module at '%s')", name, _path); }
}


string inPath(string ph) {
	string md;

	foreach(i; lLocals.Required_Lib["sys"].__getProp__("path").__array__)
	{
		foreach(ext; ["", ".qx"]) {
			md = buildPath(i.__str__, format("%s%s", ph, ext));

			if(exists(md))
				return absolutePath(md);
		}
	}
	return "";
}

// JUST THE IMPORT STATEMENT
void import_module(string[string] m, string[] save, HEAP* mem, uint line) {
	string work;
	string[] done;

	LdOBJECT mod = null;

	foreach(i; save) {
		work = inPath(m[i]);
		
		if(!work.length)
			throw new Exception(format("ImportError: module '%s' not found in sys.path.", m[i]));

		if(isFile(work))
			mod = read_file_module([i, work, (*mem)["-file-"].__str__], line);
		else if (isDir(work))
			mod = read_dir_module([i, work, (*mem)["-file-"].__str__], line);
		else
			throw new Exception(format("ImportError: module '%s' path '%s' should be a dir or a file."));
		
		done = i.split(dirSeparator);
		(*mem)[done[done.length - 1]] = mod;
	}
}


void cache(string htap, LdOBJECT mod) {
	imported_modules[htap] = mod;

	if(htap in Circular) {
		foreach(ref i; Circular[htap])
			i.props = mod.__props__;

		Circular.remove(htap);
	}
}

bool circular(string f) {
	if(f in Circular)
		return false;

	Circular[f] = [];
	return true;
}

void load_all_module_dir(LdOBJECT mod, string[3] htap, HEAP* mem, int line) {
	if (!("__export__" in mod.__props__))
		return;
	
	string p;

	foreach(i; (*(mod.__props__["__export__"].__ptr__)).map!(n => n.__str__)) {
		p = buildPath(htap[1], i);

		if(!exists(p)){
			p = format("%s.qx", p);
		
			if(!exists(p))
				throw new Exception(format("ImportError: Module not found\n path '%s' is not found in package %s.", i, htap[0]));
		}

		if(isFile(p))
			(*mem)[i] = read_file_module([i, p, htap[2]], line);
		
		else if(isDir(p))
			(*mem)[i] = read_dir_module([i, p, htap[2]], line);
	}
}

void directory_library(string[3] htap, string[string]*attrs, string[]*order, HEAP*mem, int line){
	LdOBJECT mod = read_dir_module(htap, line);
	string f;

	foreach(i; *order) {
		if(i == "*") {
			load_all_module_dir(mod, htap, mem, line);
			continue;
		}

		f = buildPath(htap[1], i);

		if (!exists(f)) {
			f = format("%s.qx", f);

			if(!exists(f))
				throw new Exception(format("ImportError: file attr '%s' is not found in dir module '%s'", i, htap[0]));
		}

		if(isFile(f))
			(*mem)[(*attrs)[i]] = read_file_module([i, f, htap[2]]);
		
		else if(isDir(f))
			(*mem)[(*attrs)[i]] = read_dir_module([i, f, htap[2]], line);
	}
}

void file_library(string[3] htap, string[string]*attrs, string[]*order, HEAP*mem, uint line){
	LdOBJECT mod = read_file_module(htap, line);
	auto fns = mod.__props__;

	foreach(i; *order) {
		if (i == "*") {
			foreach(k2, v2; fns) {
				if(!(endsWith(k2, "__") && startsWith(k2, "__")  || startsWith(k2, "#")))
					(*mem)[k2] = v2;
			}
		
		} else if(i in fns)
			(*mem)[(*attrs)[i]] = fns[i];
	
		else
			throw new Exception(format("ImportError: attr '%s' is not found in file module '%s'.", i, mod.__str__));
	}
}

LdOBJECT read_dir_module(string[3] htap, int line){
	LdModule mod;

	string[] list= dirEntries(htap[1], "*.qx", SpanMode.shallow, false).map!(i=>cast(string)i).array;
	string pack = buildPath(htap[1], "__pack__.qx");

	if (find(list, pack).length) {
		if (pack in imported_modules)
			return imported_modules[pack];

		if(circular(pack)) {
			HEAP _scope = _StartHeap.dup;
			_scope["-file-"] = new LdStr(pack);

			version(all) {
				auto l = _scope["-traceback-"].__ptr__;
				*l ~= new LdEnum("Proc", ["name": new LdStr(format("from %s", htap[0])), "file": new LdStr(format("%s:%d", htap[2], line))]);
			}

			mod = new LdModule(htap[0], pack, *(new _Interpreter(new _GenInter(new _Parse(new _Lex(readText(pack)).TOKENS, pack).ast).bytez, &_scope).heap));

			cache(pack, mod);

			version(all) {
				remove(*l, ((*l).length)-1);
				(*l).length--;
			}

			return mod;
		}

		mod = new LdModule(htap[0], htap[1], ["__path__": new LdStr(htap[1]), "__module__":RETURN.A]);
		Circular[pack] ~= mod;

		return mod;
	}

	if (htap[1] in imported_modules)
		return imported_modules[htap[1]];

	mod = new LdModule(htap[0], htap[1], ["__path__": new LdStr(htap[1]), "__name__": new LdStr(htap[0])]);
	cache(htap[1], mod);

	return mod;
}

LdOBJECT read_file_module(string[3] htap, uint line=0){
	LdModule mod;

	if(htap[1] in imported_modules)
		return imported_modules[htap[1]];
	
	if(circular(htap[1])) {
		HEAP _scope = _StartHeap.dup;
		_scope["-file-"] = new LdStr(htap[1]);

		version(all) {
			auto l = _scope["-traceback-"].__ptr__;
			*l ~= new LdEnum("Proc", ["name": new LdStr(format("import %s", htap[0])), "file": new LdStr(format("%s:%d", htap[2], line))]);
		}

		mod = new LdModule(htap[0], htap[1], *(new _Interpreter(new _GenInter(new _Parse(new _Lex(readText(htap[1])).TOKENS, htap[1]).ast).bytez, &_scope).heap));

		cache(htap[1], mod);

		version(all) {
			remove(*l, ((*l).length)-1);
			(*l).length--;
		}

		return mod;
	}

	mod = new LdModule(htap[0], htap[1], ["__path__": new LdStr(htap[1]), "__module__":RETURN.A]);
	Circular[htap[1]] ~= mod;

	return mod;
}

void import_library(string fpath, string[string]*attrs, string[]*order, HEAP* mem, uint line) {
	string htap = inPath(fpath);

	if(!htap.length)
		throw new Exception(format("ImportError: path '%s' is not found", fpath));

	if(isFile(htap))
		return file_library([fpath, htap, (*mem)["-file-"].__str__], attrs, order, mem, line);

	if(isDir(htap))
		return directory_library([fpath, htap, (*mem)["-file-"].__str__], attrs, order, mem, line);
}

