# Tuppy 
### Current Era: 1990

Tuppy is an absolutely dead basic (as in, supports nothing, not even more than one line) statically typed language that compiles to Javascript.

The lexer, parser, and typechecker are more or less directly lifted from [The Implementation of Functional Programming Languages (1987)](https://www.microsoft.com/en-us/research/publication/the-implementation-of-functional-programming-languages/) and [Implementing functional languages: a tutorial (1992)](https://www.microsoft.com/en-us/research/publication/implementing-functional-languages-a-tutorial/).  The goal so far has been to use as few libraries as possible and simple haskell to provide a base.

If you want to start messing with it, [this PR](https://github.com/bontaq/tuppy/pull/1) that adds support for strings is a great small tour.  It's easy to change and comprehend the whole thing since it's currently small.

Main files (in order the file goes during compilation):
1. https://github.com/bontaq/tuppy/blob/master/src/Parser.hs
As it says on the tin, it lexes (meaning to break up raw text into a series of words without whitespace or returns and whatnot), then it parses (which means to turn the lexed text into our language).  [This](https://github.com/bontaq/tuppy/blob/master/src/Parser.hs#L193) is the main function there.

2. https://github.com/bontaq/tuppy/blob/master/src/TypeChecker.hs This typechecks the language, and it is of course everyone's favorite type system: [Hindley–Milner](https://en.wikipedia.org/wiki/Hindley%E2%80%93Milner_type_system).  Another note: all the ridiculous gamma phi theta bad variable names were in the original text, so I've left them in but certainly am going to change them.

3. https://github.com/bontaq/tuppy/blob/master/src/Compiler.hs Currently incredibly tiny, it turns our language into runnable javascript.

### What puts it all together?
https://github.com/bontaq/tuppy/blob/master/app/Main.hs#L36 


### Hey what's the core language look like?
```
data Expr a
  = EVar Name             -- Variables
  | ENum Int              -- Numbers
  | EStr String           -- Strings
  | EAp (Expr a) (Expr a) -- Application
  | ELam [a] (Expr a)     -- lambda expressions like \x -> x
  | ELet                  -- Let (rec) expressions
    IsRec                 ---- boolean with True = recursive
    [(a, Expr a)]         ---- definitions
    (Expr a)              ---- body of let(rec)
```
https://github.com/bontaq/tuppy/blob/master/src/Language.hs#L14

### Hey what's the language itself look like?
```
square x = multiply x x

main = square 2
```
https://github.com/bontaq/tuppy/blob/master/examples/test3.tp


### Things to do

- To support multiple statements with the typechecker, then to delete the whole thing and rewrite it based on [Bidirectional Typechecking](http://davidchristiansen.dk/tutorials/bidirectional.pdf) which is more modern and produces better error messages.

- To add support for defining types.  As you might notice, it doesn't currently -- this is because back in the day the goal was "wholly inferred" types, meaning the entire program would have its types inferred and then checked.

- To remove the hand written parser and replace it with a real parsing library

- To support JSX

- To support CSS

- To make the bidrectional typechecker [parallel](http://www.ccs.neu.edu/home/samth/parallel-typecheck-draft.pdf)

- To support Agda-style implicits and typeclasses (big one that is probaby hard as hell)

- To pretty much become [Svelte](https://svelte.dev/) but statically radically typed


### Installation

You'll need [stack](https://docs.haskellstack.org/en/stable/README/) installed.  Then, it's easy as `stack install` and you can use it to produce Javascript like: `tuppy-exe -cf example.tp`.  Stack might install it somewhere else, or you might not have its install location in your path, so make sure to check the output from `stack install`.

To run the tests (all the Spec files), just do `stack test`
