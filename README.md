MiniJavaCompiler
================
Author: Yong Li 
Date: 04/15/2009

1. How to compile
   make
2. How to run
    ./parser < ./test/ex1
or  ./parser < ./test/err1

The features of this semantic analyzer:

1.argumented syntax trees
2.coverted IDNode to STNode
3.scoping rules enfored (unique name within the same block, all name used must be declared)
4.the numer of array dimensions when used match number of array dimensions when declared 
5.the number of argument is a method call match the number of parameter of this method declaration
6.the whole program contains only one main() method.
 
