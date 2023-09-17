module LdType;

import std.stdio;
import std.array: join;
import std.format: format;

import LdObject, LdBytes2, LdBytes, LdExec;


alias LdOBJECT[string] HEAP;


class Ld_Super_Object: LdOBJECT
{
	HEAP heap; string name;
	LdByte[] code; string[] attrs;

	LdOBJECT _self; LdOBJECT[string] props;
	
	this(string name, string[] attrs, LdByte[] code, HEAP heap, LdOBJECT _self){
		this.heap = heap;        this.name = name;
		this.code = code;        this.attrs = attrs;

		this.props = [
			"__name__": new LdStr(name),
		];

		foreach(string x, LdOBJECT y; this.__property__){
			y.__setProp__("self", _self);
			y.__setProp__("__repr__", new LdStr(join([name, ".", y.__getProp__("__name__").__str__, " (object module method)"])));

			props[x] = y;
		}
	}

	override LdOBJECT[string] __property__(){
		LdOBJECT fn;
		HEAP all;

		HEAP tmpMem = heap.dup;
		HEAP scoped = *(new _Interpreter(code, &tmpMem).heap);

		foreach(string i; attrs){
			fn = scoped[i];

			if (fn.__type__ == "function") {
				fn.__setProp__("__object__", new LdStr(name~'.'));
				fn.__setProp__("__repr__", new LdStr(join([name, ".", fn.__getProp__("__name__").__str__, " (object module method)"])));
			}
			
			all[i] = fn;
		}

		return all;
	}

	override string __type__(){ return name; }

	override LdOBJECT[string] __props__(){ return props; }

	override string __str__(){ return name ~ " (custom type)"; }
}


class LdTyp: LdOBJECT
{
	HEAP heap;
	string name;
	LdByte[] code;
	string[] attrs;
	LdOBJECT[] inherit;
	LdOBJECT[string] props;
	
	this(string name, LdOBJECT[] inherit, string[] attrs, LdByte[] code, HEAP heap){
		this.heap = heap;
		this.name = name;
		this.code = code;
		this.attrs = attrs;
		this.inherit = inherit;

		this.props = [
			"__name__": new LdStr(name),
		];

		// making object properties from even inherited objects
		foreach(LdOBJECT i; inherit ~ this){
			foreach(string x, LdOBJECT y; i.__property__)
				this.props[x] = y;
		}

		// adding the object to parent scope
		heap[name] = this;
	}

	override LdOBJECT[string] __property__(){
		LdOBJECT fn;
		HEAP all;

		HEAP tmpMem = heap.dup;
		HEAP scoped = *(new _Interpreter(code, &tmpMem).heap);

		foreach(string i; attrs){
			fn = scoped[i];

			if (fn.__type__ == "function") {
				fn.__setProp__("__object__", new LdStr(name~'.'));
				fn.__setProp__("__repr__", new LdStr(join([name, ".", fn.__getProp__("__name__").__str__, " (type module method)"])));
			}

			all[i] = fn;
		}

		return all;
	}

	override LdOBJECT __super__(LdOBJECT self){
		return new Ld_Super_Object(name, attrs, code, heap, self);
	}

	override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
		return new LdNobj(name, args, inherit, attrs, code, heap);
	}

	override string __type__(){
		return name;
	}

	override LdOBJECT[string] __props__(){ return props; }

	override string __str__(){ return name ~ " (type)"; }
}


class LdNobj: LdOBJECT
{
	HEAP heap;
	string name;
	LdByte[] code;
	string[] attrs;
	LdOBJECT[] _herit, _params;
	LdOBJECT[string] props;
	
	this(string name, LdOBJECT[] _parameters, LdOBJECT[] _herit, string[] attrs, LdByte[] code, HEAP heap) {
		this.heap = heap;
		this.name = name;
		this.code = code;
		this.attrs = attrs;
		this._herit = _herit;
		this._params = _params;

		this.props = [
				"__name__": new LdStr(name),
				"__repr__": new LdStr(format("%s (object)", name)),
			];

		// making object properties from even _herited objects
		foreach(LdOBJECT i; _herit ~ this){

			foreach(string x, LdOBJECT y; i.__property__){
				if (y.__type__ == "function") {
					y.__setProp__("self", this);
					y.__setProp__("__object__", new LdStr(name~'.'));
					y.__setProp__("__repr__", new LdStr(join([name, ".", y.__getProp__("__name__").__str__, " (object module method)"])));
				}

				props[x] = y;
			}
		}

		// calling constructor function
		if ("__init__" in props)
			props["__init__"](_parameters, 0, &heap);
	}

	override LdOBJECT[string] __property__(){
		HEAP all;

		HEAP tmpMem = heap.dup;
		HEAP* scoped = new _Interpreter(code, &tmpMem).heap;

		foreach(string i; attrs)
			all[i] = (*scoped)[i];

		return all;
	}

	override string __type__(){
		return name;
	}

	override LdOBJECT[string] __props__(){
		return props;
	}

	override string __str__(){
		return props["__repr__"].__str__;
	}
}

