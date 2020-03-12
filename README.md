# Arithmetic expression parser and interpreter

This is an excercise of building a parser and an interpreter in Lua using LPegLabel, hence taking profit from error labels.

## Grammar
```
Program -> (Cmd | Exp)*
Cmd      -> var '=' Exp
Exp       -> Exp '+' Term | Exp '-' Term | Term
Term     -> Term '*' Factor | Term '/' Factor | Factor
Factor   -> num | var | '('Exp')'
```

## Usage
First import the higher order function `genParser` with
```lua
genParser = dofile "exp_grammar.lua"
```

`genParser` receives as parameter a function that "writes to an output" when an expression is evaluated as a statement. The `print` function is used by default.

For example:
```lua
parser = genParser()
parser("3")             --> would print `3`
```
Now look at this other example:
```lua
output = {}
parser = genParser(function (val) 
        table.insert(output, val) 
    end)
parser("3 4")
print(output[2])        --> would print `4`
```
Another example with default output function:
```lua
input = [[
            a = 1/2
            a * 4
        ]]
parser(input)           --> would print `2`
```

You can read more examples (including some syntatic wrong ones) on _test.lua_ file.

## Comments about the implementation
- Currently, error recovery is not implemented.
- Parser evaluates the expressions on the fly. This implies some output results before a syntax error.