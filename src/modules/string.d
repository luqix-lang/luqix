module LdString;


import std.stdio;


import std.format: format;

import std.array: array, split, join, replace, replicate;

import std.uni;
import std.string;
import std.conv: to;

import std.algorithm.iteration: map, each;
import std.algorithm.searching: endsWith, startsWith, count, find;
import std.algorithm.comparison: cmp;

import LdObject;



class oStr: LdOBJECT
{
    LdOBJECT[string] props;

    this(){
        this.props = [
            "concat": new _Concat(),

            "strip": new _Strip(),
            "lstrip": new _LStrip(),
            "rstrip": new _RStrip(),

            "center": new _Center(),
            "ljust": new _Ljust(),
            "rjust": new _Rjust(),

            "replace": new _Replace(),
            "translate": new _Translate(),

            "split": new _Split(),
            "encode": new _Encode(),

            "join": new _Join(),
            "repeat": new _Repeat(),

            "upper": new  _Upper(),
            "lower": new  _Lower(),

            "isupper": new  _IsUpper(),
            "islower": new  _IsLower(),

            "capitalize": new _Capital(),

            "startswith": new _StartsWith(),
            "endswith": new _EndsWith(),

            "count": new _Count(),
            "isnumeric": new _IsNumeric(),

            "find": new _Find(),
            "format": new _Format(),

            "indexof": new _IndexOf(),
            "index": new _Index(),

            "isalpha": new _IsAlpha(),
            "isalnum": new _IsAlnum(),

            "isdigit": new _IsDigit(),
            "isprintable": new _IsPrintable(),

            "sort": new _Sort(),
        ];
    }

    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        if(args.length)
            return new LdStr(args[0].__str__);
        
        return new LdStr("");
    }

    override LdOBJECT[string] __props__(){ return props; }

    override string __str__(){ return "string (native module)"; }
}


class _Repeat: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        return new LdStr(replicate(args[0].__str__, cast(size_t)args[1].__num__));
    }
    override string __str__() { return "string.repeat (method)"; }
}

class _Strip: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        if (args.length > 1)
            return new LdStr(strip(args[0].__str__, args[1].__str__));
        
        return new LdStr(strip(args[0].__str__));
    }
    override string __str__() { return "string.strip (method)"; }
}

class _LStrip: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        if (args.length > 1)
            return new LdStr(stripLeft(args[0].__str__, args[1].__str__));
        
        return new LdStr(stripLeft(args[0].__str__));
    }
    override string __str__() { return "string.lstrip (method)"; }
}

class _RStrip: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        if (args.length > 1)
            return new LdStr(stripRight(args[0].__str__, args[1].__str__));
        
        return new LdStr(stripRight(args[0].__str__));
    }
    override string __str__() { return "string.rstrip (method)"; }
}

class _Replace: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        return new LdStr((args[0].__str__).replace(args[1].__str__, args[2].__str__));
    }

    override string __str__() { return "string.replace (method)"; }
}

class _Translate: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        string[dchar] transTable;

        foreach(k, v; args[1].__hash__)
            transTable[k[0]] = v.__str__;

        if(args.length > 2)
            return new LdStr(translate(args[0].__str__, transTable, args[2].__str__));

        return new LdStr(translate(args[0].__str__, transTable));
    }

    override string __str__() { return "string.translate (method)"; }
}

class _Center: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        if(args.length > 2)
            return new LdStr(center(args[0].__str__, cast(size_t)args[1].__num__, args[2].__str__[0]));

        return new LdStr(center(args[0].__str__, cast(size_t)args[1].__num__));
    }

    override string __str__() { return "string.center (method)"; }
}

class _Ljust: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        if(args.length > 2)
            return new LdStr(leftJustify(args[0].__str__, cast(size_t)args[1].__num__, args[2].__str__[0]));

        return new LdStr(leftJustify(args[0].__str__, cast(size_t)args[1].__num__));
    }

    override string __str__() { return "string.ljust (method)"; }
}

class _Rjust: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        if(args.length > 2)
            return new LdStr(rightJustify(args[0].__str__, cast(size_t)args[1].__num__, args[2].__str__[0]));

        return new LdStr(rightJustify(args[0].__str__, cast(size_t)args[1].__num__));
    }

    override string __str__() { return "string.rjust (method)"; }
}

class _Encode: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        return new LdChr(cast(char[])args[0].__str__);
    }

    override string __str__() { return "string.encode (method)"; }
}

class _Split: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        string[] arr;

        if (args.length > 1)
            arr = split(args[0].__str__, args[1].__str__);
        else
            arr = (args[0].__str__).split;

        return new LdArr(cast(LdOBJECT[])arr.map!(n => new LdStr(n)).array);
    }
    override string __str__() { return "string.split (method)"; }
}

class _Concat: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        string x;
        args.each!(i => x~=i.__str__);
        return new LdStr(x);
    }

    override string __str__() { return "string.add (method)"; }
}

class _Join: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        if(args.length > 1)
            return new LdStr(args[0].__array__.map!(i => i.__str__).join(args[1].__str__));

        return new LdStr(args[0].__array__.map!(i => i.__str__).join);
    }

    override string __str__() { return "string.join (method)"; }
}

class _Upper: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        return new LdStr(toUpper(args[0].__str__));
    }
    override string __str__() { return "string.upper (method)"; }
}

class _Lower: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        return new LdStr(toLower(args[0].__str__));
    }
    override string __str__() { return "string.lower (method)"; }
}

class _Capital: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        return new LdStr(capitalize(args[0].__str__));
    }
    override string __str__() { return "string.capitalize (method)"; }
}

class _IsNumeric: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        if(isNumeric(args[0].__str__))
            return RETURN.B;

        return RETURN.C;
    }
    override string __str__() { return "string.isnumeric (method)"; }
}

class _StartsWith: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        if((args[0].__str__).startsWith(args[1].__str__))
            return RETURN.B;

        return RETURN.C;
    }
    override string __str__() { return "string.startswith (method)"; }
}

class _EndsWith: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        if((args[0].__str__).endsWith(args[1].__str__))
            return RETURN.B;

        return RETURN.C;
    }
    override string __str__() { return "string.endswith (method)"; }
}

class _Count: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        return new LdNum(count(args[0].__str__, args[1].__str__));
    }
    override string __str__() { return "string.count (method)"; }
}

class _Find: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        size_t x = find(args[0].__str__, args[1].__str__).length;

        if (x==0)
            return new LdNum(-1);
        
        return new LdNum((args[0].__str__).length-x);
    }
    override string __str__() { return "string.find (method)"; }
}

class _IndexOf: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        return new LdNum(indexOf(args[0].__str__, args[1].__str__));
    }
    override string __str__() { return "string.indexof (method)"; }
}

class _Index: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        if(args.length > 2)
            return new LdStr((args[0].__str__)[cast(size_t)args[1].__num__ .. cast(size_t)args[2].__num__]);

        return new LdStr(to!string(args[0].__str__[cast(size_t)args[1].__num__]));
    }
    override string __str__() { return "string.index (method)"; }
}

class _Format: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        auto s = split(args[0].__str__, "{}");
        string gen;

        for(size_t i; i < s.length-1; i++)
            gen ~= s[i] ~ args[i+1].__str__;

        gen ~= s[s.length-1];

        return new LdStr(gen);
    }
    override string __str__() { return "string.format (method)"; }
}

class _IsAlpha: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        foreach(dchar i; args[0].__str__)
            if(!isAlpha(i))
                return RETURN.C;

        return RETURN.B;
    }
    override string __str__() { return "string.isalpha (method)"; }
}

class _IsAlnum: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        foreach(dchar i; args[0].__str__)
            if(!isNumber(i))
                return RETURN.C;

        return RETURN.B;
    }
    override string __str__() { return "string.isalnum (method)"; }
}

// C Functions
import core.stdc.ctype: isdigit, isprint, isspace, isupper, islower;

class _IsLower: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        foreach(dchar i; args[0].__str__)
            if(isupper(i))
                return RETURN.C;

        return RETURN.B;
    }
    override string __str__() { return "string.islower (method)"; }
}

class _IsUpper: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        foreach(dchar i; args[0].__str__)
            if(islower(i))
                return RETURN.C;

        return RETURN.B;
    }
    override string __str__() { return "string.isupper (method)"; }
}

class _IsDigit: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        foreach(dchar i; args[0].__str__)
            if(!isdigit(i))
                return RETURN.C;

        return RETURN.B;
    }
    override string __str__() { return "string.isdigit (method)"; }
}

class _IsPrintable: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        foreach(dchar i; args[0].__str__)
            if(!isprint(i))
                return RETURN.C;

        return RETURN.B;
    }
    override string __str__() { return "string.isprintable (method)"; }
}

class _IsSpace: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        foreach(dchar i; args[0].__str__)
            if(!isspace(i))
                return RETURN.C;

        return RETURN.B;
    }
    override string __str__() { return "string.isspace (method)"; }
}


void sort_list(LdOBJECT[] n) {
    LdOBJECT temp;

    for(size_t i = 0; i < (n.length-1); i++){
        size_t n_min = i;

        for(size_t j = i + 1; j < n.length; j++)
            if (cmp(n[j].__str__, n[n_min].__str__) < 0){
                n_min = j;
            }

        if (n_min != i) {
            temp = n[i];
            n[i] = n[n_min];
            n[n_min] = temp;
        }
    }
}


class _Sort: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        sort_list(args[0].__array__);
        return RETURN.B;
    }
    override string __str__() { return "string.sort (method)"; }
}

