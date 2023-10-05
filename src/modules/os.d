module Os;


import core.stdc.stdlib: system, getenv, abort;
import std.string: toStringz;
import std.algorithm.iteration: map;

import std.conv: to;
import std.array: array;

import std.file;
import std.path;

import LdObject;

alias LdOBJECT[string] Heap;


class oS: LdOBJECT
{
	Heap props;

	this(){
		this.props = [
            "abort": new _Abort(),
            "arch": new _Arch(),

            "system": new _System(),
            "getenv": new _Getenv(),

            "chdir": new _Chdir(),
            "getcwd": new _Getcwd(),
            
            "readdir": new _Readdir(),
            "walkdir": new _Walkdir(),

            "copy": new _Copy(),
            "rename": new _Rename(),
            "remove": new _Remove(),

            "mkdirs": new _Mkdirs(),
            "rmdirs": new _Rmdirs(),

            "tempdir": new _Tempdir(),
			"platform": new LdStr(Platform),
		];
	}

	override LdOBJECT[string] __props__(){ return props; }

	override string __str__(){ return "os (core module)"; }
}


class _Abort: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        abort();
        return RETURN.A;
    }

    override string __str__() { return "os.abort (method)"; }
}


class _Getenv: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        return new LdStr(to!string(getenv(toStringz(args[0].__str__))));
    }

    override string __str__() { return "os.getenv (method)"; }
}


class _System: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        return new LdNum(system(toStringz(args[0].__str__)));
    }

    override string __str__() { return "os.system (method)"; }
}

class _Tempdir: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        return new LdStr(tempDir);
    }

    override string __str__() { return "os.tempdir (method)"; }
}


class _Readdir: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        string htap;

        if (args.length)
            htap = args[0].__str__;
        else
            htap = getcwd();

        LdOBJECT[] paths = cast(LdOBJECT[])dirEntries(htap, SpanMode.shallow, false).map!(i => new LdStr(i)).array;
        return new LdArr(paths);
    }

    override string __str__() { return "os.readdir (method)"; }
}


class _Walkdir: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        string htap;

        if (args.length)
            htap = args[0].__str__;
        else
            htap = getcwd();

        LdOBJECT[] paths = cast(LdOBJECT[])dirEntries(htap, SpanMode.depth, false).map!(i => new LdStr(i)).array;
        return new LdArr(paths);
    }

    override string __str__() { return "os.walkdir (method)"; }
}


class _Mkdirs: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        mkdirRecurse(args[0].__str__);
        return RETURN.A;
    }

    override string __str__() { return "os.mkdirs (method)"; }
}

class _Rmdirs: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        rmdirRecurse(args[0].__str__);
        return RETURN.A;
    }

    override string __str__() { return "os.rmdirs (method)"; }
}

class _Remove: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        remove(args[0].__str__);
        return RETURN.A;
    }

    override string __str__() { return "os.remove (method)"; }
}

class _Rename: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        rename(args[0].__str__, args[1].__str__);
        return RETURN.A;
    }

    override string __str__() { return "os.rename (method)"; }
}

class _Copy: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        copy(args[0].__str__, args[1].__str__);
        return RETURN.A;
    }

    override string __str__() { return "os.copy (method)"; }
}

class _Getcwd: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        return new LdStr(getcwd);
    }

    override string __str__() { return "os.getcwd (method)"; }
}

class _Chdir: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        chdir(args[0].__str__);
        return RETURN.A;
    }

    override string __str__() { return "os.chdir (method)"; }
}


class _Arch: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        version (X86_64){
            return new LdStr("X86_64");

        } version (X86) {
            return new LdStr("X86");
        }

        return new LdStr("not_found");
    }

    override string __str__() { return "os.arch (method)"; }
}


string Platform() {
    string plat = "not_found";

    version (Windows){
        plat = "windows";

    } version (linux){
        plat = "linux";

    } version (FreeBSD){
        plat = "freeBSD";

    } version (OpenBSD){
        plat = "openBSD";

    } version (NetBSD){
        plat = "netBSD";

    } version (DragonFlyBSD){
        plat = "dragonFlyBSD";

    } version (FreeBSD){
        plat = "freeBSD";

    } version (BSD){
        plat = "BSD";

    } version (OSX){
        plat = "OSX";

    } version (IOS){
        plat = "iOS";

    } version (Android){
        plat = "android";

    } version (Solaris){
        plat = "solaris";

    }
    return plat;
}

