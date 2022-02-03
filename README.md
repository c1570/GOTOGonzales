# GOTO Gonzales
https://github.com/c1570/GOTOGonzales

The C64's [GOTO](https://www.c64-wiki.com/wiki/GOTO) command uses a short but slow implementation.
Whenever the GOTO destination is the current program line or comes before it, the BASIC interpreter starts scanning the program from the beginning.
This means that most GOTOs targeting the end of a long program take rather long.

As an example, `1000 I=I+1:GOTO1000` as a single line program takes about 850 milliseconds to complete.
The same line as the 1000th line in a program takes about 7000 milliseconds to complete.

BASIC compilers fix this issue, but still, coming up with an optimized routine is a nice challenge.

**GOTO Gonzales** patches the BASIC ROM's FNDLIN routine and sets up a small cache to speed up line offset lookups.

## Benchmarks
* fndlnc_test, standard GOTO: 8063300 cycles
* fndlnc_test, GOTOGonzales1: 2026000 cycles
* Gold Quest 6, standard GOTO: 85200000 cycles
* Gold Quest 6, GOTOGonzales1: 83400000 cycles
