module lPath;

import std.format: format;
import std.algorithm.searching: find;
import std.algorithm.iteration: each, map;

import std.array: array;

import std.file;
import std.path;

import LdObject;

alias LdOBJECT[string] Heap;


class oPath: LdOBJECT
{
	Heap props;

	this(){
		this.props = [
            "exists": new _Exists(),

			"isfile": new _IsFile(),
            "isdir": new _IsDir(),
            "islink": new _IsLink(),
			"isvalidname": new _Isvalidname(),
			
			"join": new _Join(),

			"abspath": new _Abspath(),
			"relpath": new _Relpath(),

			"dirname": new _Dirname(),
			"basename": new _Basename(),
			
			"pathsep": new LdStr(pathSeparator),
			"sep": new LdStr(dirSeparator),

            "exptilde": new _ExpandTilde(),
		];
	}

	override LdOBJECT[string] __props__(){ return props; }

	override string __str__(){ return "path (native module)"; }
}


class _Basename: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
    	return new LdStr(baseName(args[0].__str__));
    }

    override string __str__() { return "path.basename (method)"; }
}

class _ExpandTilde: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        version (POSIX){
            return new LdStr(expandTilde(args[0].__str__));
        }

        return new LdStr("");
    }

    override string __str__() { return "path.exptilde (method)"; }
}

class _Dirname: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
    	return new LdStr(dirName(args[0].__str__));
    }

    override string __str__() { return "path.dirname (method)"; }
}

class _Abspath: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
    	return new LdStr(absolutePath(args[0].__str__));
    }

    override string __str__() { return "path.abspath (method)"; }
}

class _Relpath: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
    	return new LdStr(relativePath(args[0].__str__));
    }

    override string __str__() { return "path.relpath (method)"; }
}



class _IsFile: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
    	if (isFile(args[0].__str__))
    		return new LdTrue();

    	return new LdFalse();
    }

    override string __str__() { return "path.isfile (method)"; }
}

class _IsDir: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
    	if (isDir(args[0].__str__))
    		return new LdTrue();

    	return new LdFalse();
    }

    override string __str__() { return "path.isdir (method)"; }
}

class _IsLink: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        if (isSymlink(args[0].__str__))
            return new LdTrue();

        return new LdFalse();
    }

    override string __str__() { return "path.islink (method)"; }
}

class _Isvalidname: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        if (isValidFilename(args[0].__str__))
            return new LdTrue();

        return new LdFalse();
    }

    override string __str__() { return "path.isvalidname (method)"; }
}

class _Exists: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
    	if (exists(args[0].__str__))
    		return new LdTrue();

    	return new LdFalse();
    }

    override string __str__() { return "path.exists (method)"; }
}

class _Join: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
    	string x;
    	args.each!(i => x = buildPath(x, i.__str__));

    	return new LdStr(x);
    }

    override string __str__() { return "path.join (method)"; }
}
