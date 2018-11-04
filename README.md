# rb-calculator

The calculator allows the user
- to evaluate formulas involving floating-point values and the usual arithmetic operations
- to set and reference variables that can hold the results of these calculations

The interpreter reads the input stream and breaks the input into tokens, and then an evaluator (a recursive-descent parser) parses the token stream according to the grammar and evaluates the calculator statements.

When an unexpected token is found, the program prints a message with the expected token(s) and stops parsing the statement.


## Grammar
The following grammar is used to specify the calculator program.

The language also supports empty statement and multiple statements on an input line separated by semicolons.

```
<program> ::= <statement> | <program> <statement> 
<statement> ::= <exp> | id = <exp> | clear id | list | quit | exit
<exp> ::= <term> <exp'>
<exp'> ::= + <term> <exp'> | - <term> <exp'>
<term> ::= <pow> <term'>
<term'> ::= * <pow> <term'> | / <pow> <term'>
<pow> ::= <factor> <pow'>
<pow'> ::= ** <factor> <pow'>
<factor> ::= id | number | (<exp>) | - <exp> | <function_name> (<exp>)
<function_name> ::= sqrt | tan | cos | sin | log | exp
```


## Notes

1. `id = exp` is an assignment evaluating the expression and binding that value to the given identifier. Any previous value bound to that identifier is replaced.

1. The statement `clear id` deletes the identifier from the list of known (bound) identifiers.

1. When execution begins, the identifier PI is already defined and is bound to 3.14159... (i.e., Math::PI in Ruby). It may be cleared like any other identifier.

1. The statement `list` prints all known identifiers with the values they are currently bound to.

1. The statements `quit` and `exit` have the same effect. Both terminate execution of the calculator.

1. An identifier `id` must begin with a letter, and consists of one or more letters, digits, and underscores. Upper- and lower-case letters are distinct.

1. `number` is a floating-point number, consisting of one or more digits (0-9) with an optional decimal point and an optional exponent.

1. The keywords in the grammar (`list`, `clear`, `quit`, and `exit`) are reserved and may not be used as identifiers. The built-in function name `sqrt` also is reserved and cannot be used as an identifier.

1. The arithmetic operations have their usual meaning as defined on floating-point values in Ruby. 

1. The `sqrt` function is the usual floating-point square root function.

1. Statements may contain an arbitrary amount of whitespace (tabs and spaces) before, after, and in between terminal symbols. The end of a line indicates the end of a statement.


## Possible Token Values
Below are the possible lexcial classes of the tokens as a string.

Value | Token
--|--
EOF | $
CLEAR | clear
LIST | list
QUIT | quit
EXIT | exit
SQRT | sqrt
PLUS | +
MINUS | -
POWER | **
MULT | *
DIV | /
OPENPAR | (
CLOSEPAR | )
EQUAL | =
SEMICOLON | ;
ID | any id starting with a letter or _
NUM | any integer or float number
ERROR | anything else


## Acknowledgement
Project ideas and specifications are given by Hal Perkins (from his *Programming Langauges & Implementation* course) at the University of Washington.
