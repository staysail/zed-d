// SPDX-License-Identifier: MIT
module highlighting.example; // expect: highlighting=module, example=module
import io = std.stdio; // expect: io=module, std=module, stdio=module
import std.stdio : writeln;

/// A documented aggregate. // expect: ///=comment.doc
struct Record { // expect: Record=type
    int count; // expect: count=property
    auto cached = 1; // expect: cached=property
    void update(int amount) {} // expect: update=function.definition, amount=variable.parameter
}
interface Reader { // expect: Reader=type.interface
    int read(); // expect: read=function.definition
}
union Storage { int integer; } // expect: Storage=type, integer=property
class Worker : Reader { // expect: Worker=type, Reader=type
    override int read() { return 0; }
}
enum Color { red, green = 1 } // expect: Color=type, red=constant, green=constant
enum Other { first = answer } // expect: first=constant, answer=variable
enum answer = 42; // expect: answer=constant
enum { int limit = 10 } // expect: limit=constant
alias Count = int; // expect: Count=type
alias int Index; // expect: Index=type
template Box(T, int size, alias callback, Args...) { // expect: Box=type, T=type, size=variable.parameter, callback=variable.parameter, Args=type
    T value;
}
template Defaults(T = Record, int amount = answer, alias callback = handler) {} // expect: T=type, Record=type, amount=variable.parameter, answer=variable, callback=variable.parameter, handler=variable

@safe void attributes() {} // expect: @=attribute, safe=attribute, attributes=function.definition
@tag(answer) void tagged() {} // expect: tag=attribute, answer=variable, tagged=function.definition
@tag!(int)(answer) void templatedAttribute() {} // expect: tag=attribute, answer=variable

void main() { // expect: main=function.definition
    writeln("hello"); // expect: writeln=function
    writeln!string("hello"); // expect: writeln=function, string=type.builtin
    std.stdio.writeln("hello"); // expect: writeln=function.method
    auto record = Record(); // expect: record=variable, Record=function
    record.update(1); // expect: update=function.method
    record.update!int(1); // expect: update=function.method
    factory().update(1); // expect: factory=function, update=function.method
    consume(record.count); // expect: consume=function, count=property
    auto selected = record.count; // expect: selected=variable, count=property
    pkg.Record qualified; // expect: pkg=module, Record=type, qualified=variable
    Box!(int, answer) box; // expect: Box=type, answer=variable, box=variable
    Record[limit] items; // expect: Record=type, limit=variable, items=variable
    auto number = 123; // expect: number=variable, 123=number
    auto character = 'x'; // expect: character=variable, 'x'=string
    auto enabled = true; // expect: enabled=variable, true=boolean
    auto missing = null; // expect: missing=variable, null=constant.language
    auto upper = MAX_COUNT; // expect: MAX_COUNT=constant
    int UPPER; // expect: UPPER=variable
    auto lambda = input => input + 1; // expect: lambda=variable, input=variable.parameter
    auto typedLambda = (int argument) => argument; // expect: argument=variable.parameter
    auto inferredLambda = (left, right) => left + right; // expect: left=variable.parameter, right=variable.parameter
    auto delegateLiteral = delegate int(int argument) { return argument; }; // expect: argument=variable.parameter
    auto anonymousDefault = delegate int(int = answer) { return 0; }; // expect: answer=variable
    auto constantDefault = delegate int(int = MAX_COUNT) { return 0; }; // expect: MAX_COUNT=constant
    auto defaultLambda = (int argument = answer) => argument; // expect: argument=variable.parameter, answer=variable
    foreach (int index; [1, 2]) {} // expect: index=variable.parameter, ]=punctuation.bracket
    foreach (entry; items) {} // expect: entry=variable.parameter
    auto sliceLength = items[0 .. $].length; // expect: $=variable.special, length=property
    auto text = "hello\n"; // expect: \n=string.escape
    auto interpolated = i"value $(record.count)"; // expect: $(=punctuation.special, count=property
    auto allocated = new Worker; // expect: new=keyword, Worker=type
    auto trait = __traits(compiles, writeln("test")); // expect: compiles=function.builtin, writeln=function
    pragma(msg, "test"); // expect: msg=function.builtin
}

void parameters(int value, Record item, int fallback = answer) {} // expect: value=variable.parameter, item=variable.parameter, fallback=variable.parameter, answer=variable
void unnamed(int = answer) {} // expect: answer=variable
void unnamedCall(int = compute(answer)) {} // expect: compute=function, answer=variable
void unnamedVariadic(int = answer...) {} // expect: answer=variable
void variadic(int values...) {} // expect: values=variable.parameter, ...=punctuation.special
void attributed(@tag(answer) int value) {} // expect: tag=attribute, answer=variable, value=variable.parameter
void defaults(int value = compute(answer)) {} // expect: value=variable.parameter, compute=function, answer=variable
void contract() out(result; result > 0) {} // expect: result=variable.parameter
struct Owned {
    this(int value) {} // expect: this=function.definition, value=variable.parameter
    ~this() {} // expect: this=function.definition
    this(this) {} // expect: this=function.definition
}
ref int reference(ref int value) @safe { return value; } // expect: ref=keyword.storage, value=variable.parameter, safe=attribute
void identity() { auto result = 1 is 1; } // expect: is=operator

/** Block documentation. */ // expect: /**=comment.doc
/++ Nested documentation. +/ // expect: /++=comment.doc
// Ordinary comment. // expect: Ordinary=comment
cdouble legacy; // expect: cdouble=type.deprecated
double normal; // expect: double=type.builtin
