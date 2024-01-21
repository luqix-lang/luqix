module LdBytes2;


import std.conv;
import std.stdio;

import std.algorithm.iteration: map;
import std.algorithm.searching: find;
import std.format: format;
import std.array: array, join;

import LdObject, LdType, LdBytes;


alias LdOBJECT[string] HEAP;



// NUMBERS 1  1.5 100_000

class Op_Num: LdByte {
	LdOBJECT _num;

	this(double number){
		this._num = new LdNum(number);
	}

	override LdOBJECT opCall(HEAP* _heap) {
		return this._num;
	}
}

class Op_Add: LdByte {
	LdByte left, right;

	this(LdByte left, LdByte right){
		this.left = left;
		this.right = right;
	}

	override LdOBJECT opCall(HEAP* _heap) {
		return new LdNum(left(_heap).__num__ + right(_heap).__num__);
	}
}

class Op_Minus: LdByte {
	LdByte left, right;

	this(LdByte left, LdByte right){
		this.left = left;
		this.right = right;
	}

	override LdOBJECT opCall(HEAP* _heap) {
		return new LdNum(left(_heap).__num__ - right(_heap).__num__);
	}
}

class Op_Times: LdByte {
	LdByte left, right;

	this(LdByte left, LdByte right){
		this.left = left;
		this.right = right;
	}

	override LdOBJECT opCall(HEAP* _heap) {
		return new LdNum(left(_heap).__num__ * right(_heap).__num__);
	}
}

class Op_Divide: LdByte {
	LdByte left, right;

	this(LdByte left, LdByte right){
		this.left = left;
		this.right = right;
	}

	override LdOBJECT opCall(HEAP* _heap) {
		return new LdNum(left(_heap).__num__ / right(_heap).__num__);
	}
}

class Op_Remainder: LdByte {
	LdByte left, right;

	this(LdByte left, LdByte right){
		this.left = left;
		this.right = right;
	}

	override LdOBJECT opCall(HEAP* _heap) {
		return new LdNum(left(_heap).__num__ % right(_heap).__num__);
	}
}

class Op_Equals: LdByte {
	LdByte left, right;

	this(LdByte left, LdByte right){
		this.left = left;
		this.right = right;
	}

	override LdOBJECT opCall(HEAP* _heap) {
		if (left(_heap).__str__ == right(_heap).__str__)
			return RETURN.B;

		return RETURN.C;
	}
}

class Op_Less: LdByte {
	LdByte left, right;

	this(LdByte left, LdByte right){
		this.left = left;
		this.right = right;
	}

	override LdOBJECT opCall(HEAP* _heap) {
		if (left(_heap).__num__ < right(_heap).__num__)
			return RETURN.B;

		return RETURN.C;
	}
}

class Op_Great: LdByte {
	LdByte left, right;

	this(LdByte left, LdByte right){
		this.left = left;
		this.right = right;
	}

	override LdOBJECT opCall(HEAP* _heap) {
		if (left(_heap).__num__ > right(_heap).__num__)
			return RETURN.B;

		return RETURN.C;
	}
}

class Op_Lequals: LdByte {
	LdByte left, right;

	this(LdByte left, LdByte right){
		this.left = left;
		this.right = right;
	}

	override LdOBJECT opCall(HEAP* _heap) {
		if (left(_heap).__num__ <= right(_heap).__num__)
			return RETURN.B;

		return RETURN.C;
	}
}

class Op_Gequals: LdByte {
	LdByte left, right;

	this(LdByte left, LdByte right){
		this.left = left;
		this.right = right;
	}

	override LdOBJECT opCall(HEAP* _heap) {
		if (left(_heap).__num__ >= right(_heap).__num__)
			return RETURN.B;

		return RETURN.C;
	}
}

class Op_B_AND: LdByte {
	LdByte left, right;

	this(LdByte left, LdByte right){
		this.left = left;
		this.right = right;
	}

	override LdOBJECT opCall(HEAP* _heap) {
		return new LdNum(((cast(int)left(_heap).__num__)) & (cast(int)(right(_heap).__num__)));
	}
}

class Op_B_OR: LdByte {
	LdByte left, right;

	this(LdByte left, LdByte right){
		this.left = left;
		this.right = right;
	}

	override LdOBJECT opCall(HEAP* _heap) {
		return new LdNum(((cast(int)left(_heap).__num__)) | (cast(int)(right(_heap).__num__)));
	}
}

class Op_B_XOR: LdByte {
	LdByte left, right;

	this(LdByte left, LdByte right){
		this.left = left;
		this.right = right;
	}

	override LdOBJECT opCall(HEAP* _heap) {
		return new LdNum(((cast(int)left(_heap).__num__)) ^ (cast(int)(right(_heap).__num__)));
	}
}

class Op_B_Lshift: LdByte {
	LdByte left, right;

	this(LdByte left, LdByte right){
		this.left = left;
		this.right = right;
	}

	override LdOBJECT opCall(HEAP* _heap) {
		return new LdNum(((cast(int)left(_heap).__num__)) << (cast(int)(right(_heap).__num__)));
	}
}

class Op_B_Rshift: LdByte {
	LdByte left, right;

	this(LdByte left, LdByte right){
		this.left = left;
		this.right = right;
	}

	override LdOBJECT opCall(HEAP* _heap) {
		return new LdNum(((cast(int)left(_heap).__num__)) >> (cast(int)(right(_heap).__num__)));
	}
}


class Op_NOTequals: LdByte {
	LdByte left, right;

	this(LdByte left, LdByte right){
		this.left = left;
		this.right = right;
	}

	override LdOBJECT opCall(HEAP* _heap) {
		if (left(_heap).__str__ != right(_heap).__str__)
			return RETURN.B;

		return RETURN.C;
	}
}



// STRINGS 'hello', "world"

class Op_Str: LdByte {
	LdOBJECT _str;

	this(string st){
		this._str = new LdStr(st);
	}

	override LdOBJECT opCall(HEAP* _heap) {
		return _str;
	}
}


class Op_Array: LdByte {
	LdByte[] items;

	this(LdByte[] items){
		this.items = items;
	}

	override LdOBJECT opCall(HEAP* _heap) {
		LdOBJECT[] arr;

		foreach(LdByte i; items)
			arr ~= i(_heap);

		return new LdArr(arr);
	}
}


// HASH  {.:.}

class Op_Hash: LdByte {
	string[] keys;
	LdByte[] values;

	this(string[] keys, LdByte[] values){
		this.keys = keys;
		this.values = values;
	}

	override LdOBJECT opCall(HEAP* _heap) {
		LdOBJECT[string] hash;

		for(int i = 0; i < keys.length; i++)
			hash[keys[i]] = values[i](_heap);

		return new LdHsh(hash);
	}
}


// ENUM  {.=.}

class Op_Enum: LdByte {
	string[] keys;
	LdByte[] values;

	this(string[] keys, LdByte[] values){
		this.keys = keys;
		this.values = values;
	}

	override LdOBJECT opCall(HEAP* _heap) {
		LdOBJECT[string] hash;
		string name;

		for(int i = 0; i < keys.length; i++)
			hash[keys[i]] = values[i](_heap);

		return new LdEnum(format("Enum(%s)", join(keys, ", ")), hash);
	}
}


// INDEXING [1,'a'][1]  x[2] = 1

class Op_Pindex: LdByte {
	LdByte value, index;

	this(LdByte value, LdByte index){
		this.value = value;
		this.index = index;
	}

	override LdOBJECT opCall(HEAP* _heap) {
		return value(_heap).__index__(index(_heap));
	}
}


class Op_PiAssign: LdByte {
	LdByte key, index, value;

	this(LdByte key, LdByte index, LdByte value){
		this.key = key;
		this.index = index;
		this.value = value;
	}

	override LdOBJECT opCall(HEAP* _heap) {
		key(_heap).__assign__(index(_heap), value(_heap));
		return RETURN.A;
	}
}


class Op_Pobj: LdByte {
	string name;
	string[] attrs;
	LdByte[] base, code;

	this(string name, LdByte[] base, string[] attrs, LdByte[] code){
		this.name = name;
		this.code = code;
		this.attrs = attrs;
		this.base = base;
	}

	override LdOBJECT opCall(HEAP* _heap){
		LdOBJECT[] dna;

		foreach(LdByte i; base)
			dna ~= i(_heap);

		return new LdTyp(name, dna, attrs, code, *_heap);
	}
}


// GETTING ATTRIBUTE x.y x.y = 3

class Op_Pdot: LdByte {
	LdByte obj;
	string prop;

	this(LdByte obj, string prop){
		this.obj = obj;
		this.prop = prop;
	}

	override LdOBJECT opCall(HEAP* _heap) {
		return obj(_heap).__getProp__(prop);
	}
}

class Op_Pdot_2: LdByte {
	string key;
	LdByte[] args;

	this(string key, LdByte[] args){
		this.key = key;
		this.args = args;
	}

	override LdOBJECT opCall(HEAP* _heap) {
		auto fn = (*_heap)[key];
		LdOBJECT[] par = args.map!(i => i(_heap)).array;

		return fn(par);
	}
}


class Op_PdotAssign: LdByte {
	LdByte obj, value;
	string prop;

	this(LdByte obj, string prop, LdByte value){
		this.obj = obj;
		this.prop = prop;
		this.value = value;
	}

	override LdOBJECT opCall(HEAP* _heap) {
		obj(_heap).__setProp__(prop, value(_heap));
		return RETURN.A;
	}
}




// BOOLEANS  true false and none

class Op_True: LdByte {
	override LdOBJECT opCall(HEAP* _heap) {
		return RETURN.B;
	}
}

class Op_False: LdByte {
	override LdOBJECT opCall(HEAP* _heap) {
		return RETURN.C;
	}
}

class Op_None: LdByte {
	override LdOBJECT opCall(HEAP* _heap) {
		return RETURN.A;
	}
}



// NOT OR and AND

class Op_Not: LdByte {
	LdByte value;

	this(LdByte value){
		this.value = value;
	}

	override LdOBJECT opCall(HEAP* _heap) {
		if(!value(_heap).__true__)
			return RETURN.B;

		return RETURN.C;
	}
}

class Op_Or: LdByte {
	LdByte left, right;

	this(LdByte left, LdByte right){
		this.left = left;
		this.right = right;
	}

	override LdOBJECT opCall(HEAP* _heap) {
		auto firstOption = left(_heap);

		if (firstOption.__true__)
			return firstOption;

		return right(_heap);
	}
}

class Op_And: LdByte {
	LdByte left, right;

	this(LdByte left, LdByte right){
		this.left = left;
		this.right = right;
	}

	override LdOBJECT opCall(HEAP* _heap) {
		auto option = left(_heap);

		if (!(option.__true__))
			return option;

		return right(_heap);
	}
}

class Op_In: LdByte {
	LdByte left, right;

	this(LdByte left, LdByte right){
		this.left = left;
		this.right = right;
	}

	override LdOBJECT opCall(HEAP* _heap) {
		if(find(right(_heap).__str__, left(_heap).__str__).length)
			return RETURN.B;

		return RETURN.C;
	}
}

