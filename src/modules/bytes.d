module LdChar;


import std.stdio;
import std.format: format;

import std.algorithm.iteration: each;
import std.algorithm.mutation: remove, reverse;


import LdObject;


class oBytes: LdOBJECT
{
    LdOBJECT[string] props;

    this(){
        this.props = [
            "append": new _Append(),
            "decode": new _Decode(),

            "to_byte_array": new _toByteArray(),

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

class _toByteArray: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        return new _ByteArrayObject(cast(ubyte[])(args[0].__chars__));
    }

    override string __str__() { return "bytes.to_byte_array (type)"; }
}


class _ByteArrayObject: LdOBJECT
{
    ubyte[] bits;
    LdOBJECT[string] props;

    this(ubyte[] bits){
        this.bits = bits;

        this.props = [
            "decode": new _ByteArray_decode(this),
            "int_array": new _ByteArray_int_array(this),
            
            "append": new _ByteArray_append(this),
            "pop": new _ByteArray_pop(this),

            "index": new _ByteArray_index(this),
        ];
    }

    override LdOBJECT __index__(LdOBJECT arg){
        return new LdChr(cast(char[])([this.bits[cast(size_t)arg.__num__]]));
    }

    override double __true__(){ return cast(double)bits.length; }

    override LdOBJECT[string] __props__(){ return props; }

    override size_t __length__() { return this.bits.length; }

    override string __type__(){ return "byte_array"; }

    override string __str__(){ return format("bytes.byte_array (object)"); }
}

class _ByteArray_decode: LdOBJECT {
    _ByteArrayObject data;

    this(_ByteArrayObject data) { this.data = data; }

    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        return new LdChr(cast(char[])this.data.bits);
    }

    override string __str__() { return "decode (bytes.byte_array method)"; }
}


class _ByteArray_int_array: LdOBJECT {
    _ByteArrayObject data;

    this(_ByteArrayObject data) { this.data = data; }

    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        LdOBJECT[] ls;
        this.data.bits.each!(i => ls ~= new LdNum(i));

        return new LdArr(ls);
    }

    override string __str__() { return "int_array (bytes.byte_array method)"; }
}

class _ByteArray_append: LdOBJECT {
    _ByteArrayObject data;

    this(_ByteArrayObject data) { this.data = data; }

    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        this.data.bits ~= cast(ubyte)args[0].__num__;
        return RETURN.A;
    }

    override string __str__() { return "append (bytes.byte_array method)"; }
}

class _ByteArray_pop: LdOBJECT {
    _ByteArrayObject data;

    this(_ByteArrayObject data) { this.data = data; }

    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        size_t i;

        if (args.length)
            i = cast(size_t)args[0].__num__;
        else
            i = cast(size_t)(data.bits.length)-1;

        auto popped = (data.bits)[i];
        remove(data.bits, i);

        // setting array to its new length
        (data.bits).length--;

        return new LdChr(cast(char[])[popped]);
    }

    override string __str__() { return "pop (bytes.byte_array method)"; }
}

class _ByteArray_index: LdOBJECT {
    _ByteArrayObject data;

    this(_ByteArrayObject data) { this.data = data; }

    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        if(args.length > 1) {
            ubyte[] got = (data.bits)[cast(size_t)args[0].__num__ .. cast(size_t)args[1].__num__];
            return new LdChr(cast(char[])got);
        }

        return new LdChr(
            cast(char[])([(data.bits)[cast(size_t)args[0].__num__]])
        );
    }

    override string __str__() { return "index (bytes.byte_array method)"; }
}


