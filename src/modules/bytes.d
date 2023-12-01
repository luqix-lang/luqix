module LdChar;


import std.stdio;

import std.format: format;
import std.algorithm.iteration: each;

import LdObject;


class oBytes: LdOBJECT
{
    LdOBJECT[string] props;

    this(){
        this.props = [
            "append": new _Append(),
            "decode": new _Decode(),

            "index": new _Index(),
            "byte_array": new _ByteArray(),
        ];
    }

    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        return RETURN.A;
    }

    override LdOBJECT[string] __props__(){ return props; }

    override string __str__(){ return "bytes (native module)"; }
}


class _Decode: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        return new LdStr(cast(string)(args[0].__chars__));
    }
    override string __str__() { return "bytes.decode (method)"; }
}

class _Append: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
    	char[] y;
    	args.each!(n => y ~= n.__chars__);

        return new LdChr(y);
    }

    override string __str__() { return "bytes.append (method)"; }
}


class _Index: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        if(args.length > 2)
            return new LdChr((args[0].__chars__)[cast(size_t)args[1].__num__ .. cast(size_t)args[2].__num__]);

        return new LdChr([args[0].__chars__[cast(size_t)args[1].__num__]]);
    }

    override string __str__() { return "bytes.index (method)"; }
}


class _ByteArray: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        ubyte[] bt;
        (args[0].__array__).each!(i => bt ~= cast(ubyte)i.__num__);
        return new _ByteArrayObject(bt);
    }

    override string __str__() { return "bytes.byte_array (type)"; }
}


class _ByteArrayObject: LdOBJECT
{
    ubyte[] arr;
    LdOBJECT[string] props;

    this(ubyte[] arr){
        this.arr = arr;
        this.props = [
            "decode": new _ByteArray_decode(this.arr),
            "value": new _ByteArray_value(this.arr),
        ];
    }

    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        return RETURN.A;
    }

    override LdOBJECT[string] __props__(){ return props; }

    override string __type__(){ return "byte_array"; }

    override string __str__(){ return format("bytes.byte_array (object)"); }
}

class _ByteArray_decode: LdOBJECT {
    ubyte[] arr;

    this(ubyte[] arr) { this.arr = arr; }

    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        return new LdChr(cast(char[])this.arr);
    }

    override string __str__() { return "decode (bytes.byte_array method)"; }
}


class _ByteArray_value: LdOBJECT {
    ubyte[] arr;

    this(ubyte[] arr) { this.arr = arr; }

    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        LdOBJECT[] ls;
        this.arr.each!(i => ls ~= new LdNum(i));

        return new LdArr(ls);
    }

    override string __str__() { return "value (bytes.byte_array method)"; }
}



