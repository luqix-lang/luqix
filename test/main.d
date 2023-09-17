import std.stdio;

import std.algorithm.comparison: min, max;


void main(){
	char[char] v = ['a': '1', 'b': '2'];

	writeln(v.get('j', '4'));
}
