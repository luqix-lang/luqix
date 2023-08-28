module lParallelism;

import std.parallelism;

import std.conv: to;
import std.stdio: writeln;

import LdObject;

alias LdOBJECT[string] Heap;

class oParallel: LdOBJECT
{
	Heap props;

	this(){
		this.props = [
			"Task": new _Task(),
			"for_each": new _For_Each(),
			"pool_threads": new _Pool_threads(),
			"cpu_cores": new LdNum(totalCPUs),
			"TaskPool": new _TaskPool(),
		];
	}

	override LdOBJECT[string] __props__(){ return props; }

	override string __str__(){ return "parallelism (native module)"; }
}


class _Task: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
        return new _Task_api(args);
    }
    override string __str__() { return "Task (parallelism object)"; }
}


// New task API
class _Task_api: LdOBJECT {
	Heap props;

	this(LdOBJECT[] args) {
		auto func = task!Facile_fn_wrapper(args);


		class _Exec: LdOBJECT {
			override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
				func.executeInNewThread();
				return RETURN.A;
			}
			override string __str__() { return "exec (parallelism.Task method)";}
		}


		// work, spin, yield
		// If the Task isn't started yet, execute it in the current thread.
		// If its done return its return value or result.
		// If it threw an exception, rethrow that exception.


		class _Yield: LdOBJECT {
			override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
				return func.yieldForce();
			}
			override string __str__() { return "yield (parallelism.Task method)";}
		}


		class _Work: LdOBJECT {
			override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
				return func.workForce();
			}
			override string __str__() { return "work (parallelism.Task method)";}
		}


		class _Spin: LdOBJECT {
			override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
				return func.spinForce();
			}
			override string __str__() { return "spin (parallelism.Task method)";}
		}


		class _Wait: LdOBJECT {
			override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
				while (!func.done()){ }
				return func.yieldForce();
			}
			override string __str__() { return "wait (parallelism.Task method)";}
		}

		class _Isdone: LdOBJECT {
			override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
				if (func.done())
					return RETURN.B;

				return RETURN.C;
			}
			override string __str__() { return "isdone (parallelism.Task method)";}
		}

		this.props = [
			"exec": new _Exec(),
			"work": new _Work(),
			"wait": new _Wait(),
			"spin": new _Spin(),
			"isdone": new _Isdone(),
			"yield": new _Yield(),
		];
	}

	override LdOBJECT[string] __props__(){ return props; }

	override string __str__(){ return "TaskPool (parallelism object)"; }
}



class _For_Each: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
    	
    	foreach (i; parallel(*(args[0].__ptr__))) {
		    i([]);
		}

        return RETURN.A;
    }

    override string __str__() { return "for_each (parallelism method)"; }
}


// setts and counts cores used by taskpool
class _Pool_threads: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
    	if (args.length)
    		defaultPoolThreads(cast(uint)args[0].__num__);

        return new LdNum(defaultPoolThreads);
    }

    override string __str__() { return "pool_threads (parallelism method)"; }
}


// Object to deal with taskPool API
class _TaskPool: LdOBJECT {
	Heap props;

	this() {
		this.props = [
			"add": new _Add(),
			"stop": new _Stop(),
			"finish": new _Finish(),
			"isDaemon": new _IsDaemon(),
		];
	}

	override LdOBJECT[string] __props__(){ return props; }

	override string __str__(){ return "TaskPool (parallelism object)"; }
}


// D function wrapper for facile
LdOBJECT Facile_fn_wrapper(LdOBJECT[] arg){
	return arg[0](*(arg[1].__ptr__));
}


class _Add: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
    	auto work = task!Facile_fn_wrapper(args);
		taskPool.put(work);

        return RETURN.A;
    }

    override string __str__() { return "add (parallelism.TaskPool method)"; }
}


class _Finish: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
    	if(!args.length)
    		taskPool.finish();

    	else {
			if (args[0].__true__)
				taskPool.finish(true);
			else
				taskPool.finish(false);
    	}
        return RETURN.A;
    }

    override string __str__() { return "finish (parallelism.TaskPool method)"; }
}


class _Stop: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
		taskPool.stop();
        return RETURN.A;
    }

    override string __str__() { return "stop (parallelism.TaskPool method)"; }
}

class _IsDaemon: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args, uint line=0, LdOBJECT[string]* mem=null){
		if (taskPool.isDaemon())
			return RETURN.B;

		return RETURN.C;
    }

    override string __str__() { return "isDaemon (parallelism.TaskPool method)"; }
}
