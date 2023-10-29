module lThread;

import std.stdio;
import std.concurrency; 
import core.thread;

import importlib: __setImp__, _StartHeap;

import LdObject;


alias LdOBJECT[string] Heap;


class oThread: LdOBJECT
{
	Heap props;

	this(){
		this.props = [
            "Thread": new _Thread(),
		];
	}

    override LdOBJECT[string] __props__(){ return props; }

	override string __str__(){ return "thread (core module)"; }
}


class _Thread: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){

        synchronized { 
            auto new_thread = new Thread({
                args[0](args[1].__array__, line, mem);
            });

            new_thread.start();
        }

        return RETURN.A;
    }

    override string __str__() { return "localtime (time method)"; }
}
