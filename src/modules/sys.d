module lSys;

import std.file: getcwd, thisExePath;
import std.path: buildPath, dirName;
import std.stdio;

import LdObject;


alias LdOBJECT[string] HEAP;


class oSys: LdOBJECT
{
	HEAP props;

	this(string[] argv, LdOBJECT Modules){
		this.props = [
			"getvar": new Getvar(),
			"setvar": new Setvar(),
			"delvar": new Delvar(),

			"argv": Getargv(argv),
			"path": Getpath(),

			"modules_path": Modules,
			"executable": new LdStr(thisExePath),

		];
	}

	override LdOBJECT[string] __props__(){ return props; }

	override string __str__(){ return "sys (native module)"; }
}



LdOBJECT Getargv(string[] arg)
{
	LdOBJECT[] arr;

	foreach(i; arg)
		arr ~= new LdStr(i);

	return new LdArr(arr);
}

LdOBJECT Getpath()
{
	return new LdArr([new LdStr(""), new LdStr(getcwd()), new LdStr(buildPath(getcwd(), "luqix_modules")), new LdStr(buildPath(dirName(thisExePath), "luqix_modules"))]);
}

class Getvar: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, HEAP* mem=null){
    	return (*mem)[args[0].__str__];
    }

    override string __str__() { return "sys.getvar (method)"; }
}

class Setvar: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, HEAP* mem=null){
    	(*mem)[args[0].__str__] = args[1];
    	return RETURN.A;
    }

    override string __str__() { return "sys.setvar (method)"; }
}

class Delvar: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, HEAP* mem=null){
    	if ((*mem).remove(args[0].__str__))
    		return RETURN.B;

    	return RETURN.C;
    }

    override string __str__() { return "sys.delvar (method)"; }
}
