module lNumber;


import std.stdio;
import std.conv: to;

import std.math: round, pow;
import std.algorithm.comparison: max, min;

import LdObject;



class oNumber: LdOBJECT
{
    LdOBJECT[string] props;

    this(){
        this.props = [
            "max": new _Max(),
            "min": new _Min(),
        ];
    }

    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        if(args.length)
            return new LdNum(args[0].__num__);
        
        return new LdNum(0);
    }

    override LdOBJECT[string] __props__(){ return props; }

    override string __str__(){ return "number (native module)"; }
}


class _Max: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        return new LdNum(max(args[0].__num__, args[1].__num__));
    }
    override string __str__() { return "number.max (method)"; }
}

class _Min: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        return new LdNum(min(args[0].__num__, args[1].__num__));
    }
    override string __str__() { return "number.min (method)"; }
}

