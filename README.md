# rb-calculator

Implementing a calculator that allows the user to evaluate formulas

## Notes
The calculator allows the user to evaluate formulas involving floating-point values and the usual arithmetic operations, as well as to set and reference variables that can hold the results of these calculations. The interprreter reads the input stream and breaks the input into tokens, and then an evaluator (a recursive-descent parser) parses the token stream according to the grammar and evaluates the calculator statements. When an unexpected token is found, the program prints a message with the expected token(s) and stops parsing the statement.


## Grammar
The following grammar is used to specify the calculator program. The language also supports empty statement and multiple statements on an input line separated by semicolons.

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
Project idea and specifications are given by Hal Perkins (from *Programming Langauges & Implementation*) at University of Washington.
