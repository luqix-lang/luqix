import std.stdio;
import std.socket;


void main() {
    InternetHost ih = new InternetHost;

   ih.getHostByAddr("213.36.253.2");
   writeln(ih.addrList);
   writeln(ih.name);

   //ih.getHostByAddr("127.0.0.1");
   //writeln(ih.addrList[0]);
}