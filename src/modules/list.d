module lList;


import std.stdio;

import std.algorithm.mutation: remove, reverse;
import std.array: insertInPlace;

import LdObject;



class oList: LdOBJECT
{
    LdOBJECT[string] props;

    this(){
        this.props = [
            "join": new _Join(),
            "extend": new _Extend(),

            "append": new _Append(),

            "clear": new _Clear(),
            "copy": new _Copy(),
            
            "insert": new _Insert(),
            "pop": new _Pop(),
            
            "index": new _Index(),
            "reverse": new _Reverse(),
        ];
    }

    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        return new LdStr("");
    }

    override LdOBJECT[string] __props__(){ return props; }

    override string __str__(){ return "list (native module)"; }
}


class _Join: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){ 
       	// adds and returns a new list
        return new LdArr(*(args[0].__ptr__) ~ *(args[1].__ptr__));
    }

    override string __str__() { return "list.join (method)"; }
}

class _Extend: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        // appends 2nd array to 1st array
        *(args[0].__ptr__) ~= *(args[1].__ptr__);
        return RETURN.A;
    }

    override string __str__() { return "list.extend (method)"; }
}

class _Insert: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
    	auto x = args[0].__array__;
        x.insertInPlace(cast(size_t)args[1].__num__, args[2]);

        *(args[0].__ptr__) = x;
        return RETURN.A;
    }

    override string __str__() { return "list.insert (method)"; }
}

class _Append: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
    	LdOBJECT[] *l = args[0].__ptr__;
    	*l ~= args[1];

		return RETURN.A;
    }

    override string __str__() { return "list.append (method)"; }
}

class _Index: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        if(args.length > 2)
            return new LdArr((*(args[0].__ptr__))[cast(size_t)args[1].__num__ .. cast(size_t)args[2].__num__]);

        return (*(args[0].__ptr__))[cast(size_t)args[1].__num__];
    }

    override string __str__() { return "list.index (method)"; }
}


class _Clear: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
    	auto l = args[0].__ptr__;
    	(*l).length = 0;

		return RETURN.A;
    }

    override string __str__() { return "list.clear (method)"; }
}

class _Copy: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
		return new LdArr(args[0].__array__.dup);
    }

    override string __str__() { return "list.copy (method)"; }
}

class _Reverse: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
		reverse(args[0].__array__);
		return RETURN.A;
    }

    override string __str__() { return "list.reverse (method)"; }
}

class _Pop: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
    	LdOBJECT[] *l = args[0].__ptr__;
    	uint i;

    	if (args.length > 1)
    		i = cast(uint)args[1].__num__;
    	else
    		i = cast(uint)((*l).length)-1;

        // keeping popped item
		auto popped = (*l)[i];
		remove(*l, i);

        // setting array to its new length
		(*l).length--;

		return popped;
    }

    override string __str__() { return "list.pop (method)"; }
}
