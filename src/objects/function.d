module LdFunction;

import std.algorithm.mutation: remove;

import std.stdio;
import std.format: format;
import std.array: join;

import LdObject, LdBytes2, LdBytes, LdExec;


alias LdOBJECT[string] store;



class LdFn: LdOBJECT {
	size_t def_length;
	store heap;                    string name, file;
	LdByte[] code;                 string[] params;
	LdOBJECT ret;                  LdOBJECT[] defaults;
	LdOBJECT[string] props;
	
	this(string name, string file, string[] params, LdOBJECT[] defaults, LdByte[] code, store heap){
		this.name = name;
		this.file = file;

		this.code = code;
		this.heap = heap;

		this.params = params;
		this.defaults = defaults;

		this.def_length = defaults.length;

		this.props = [
			"self": RETURN.A,
			"__object__": RETURN.A,
			"__repr__": new LdStr(format("%s (method)", name)),
			"__name__": new LdStr(name),
			"__file__": new LdStr(file),
		];
	}

	override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
		if(args.length < params.length){
			size_t def = def_length - (params.length-args.length);

			if(!(def_length && def < def_length)) {
				auto miss = params.length - args.length;

				throw new Exception(format("TypeError: %s() is missing %d args (%s)", name, miss, join(params[(params.length-miss)..params.length], ", ")));
			}

			args = args ~ defaults[def .. def_length];
		}

		// resetting for new function
		auto point = this.heap.dup;
		point["self"] = props["self"];
		point["#rt"] = RETURN.A;
		point["#rtd"] = RETURN.B;
		point["#bk"] = RETURN.B;

		for(size_t i = 0; i < params.length; i++)
			point[params[i]] = args[i];

		//auto l = point["-traceback-"].__ptr__;
		//*l ~= new LdEnum("Proc", ["name": new LdStr(name), "file": new LdStr(format("%s:%d", (*mem)["-file-"].__str__, line))]);

		auto ret_val = (*(new _Interpreter(code, &point).heap))["#rt"];

		//remove(*l, ((*l).length)-1);
		//(*l).length--;

		return ret_val;
	}

	override LdOBJECT[string] __props__(){ return props; }

	override string __str__(){ return props["__repr__"].__str__; }
}
