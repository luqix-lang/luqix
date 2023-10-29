import std.stdio; 
import std.stdio; 
import std.concurrency; 
import core.thread;
  
void worker(int a) { 
   foreach (i; 0 .. 4) { 
      //Thread.sleep(dur!"msecs"(1));
      writeln("Worker Thread ",a + i); 
   } 
}


void main() { 
   for(int i =0; i < 1000000; i++) { 
      //Thread.sleep(dur!"msecs"(2));
      writeln("Main Thread ",i);

      spawn(&worker, i*5); 
   }
   
   writeln("main is done.");  
}