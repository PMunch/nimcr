# Running Nim code with Shebangs
Shebangs are a tiny comment at the beginning of a file that tells the operating system what program can be used to run the contents of the file. It is typically seen in bash scripts starting with #!/bin/bash or in Python scripts as #!/usr/bin/env python. Nim however is not an interpreted language, this means that having a program that "runs" Nim files would actually mean compile and run. This was outlined in issue [#66](https://github.com/nim-lang/Nim/issues/66) for Nim but was closed after Araq showed how it could be achieved with flags to the compiler. However this solution is a bit lacking. Nim, being a compiled langage, offer a speed benefit over many other languages. So writing scripts in Nim makes sense if you want to have a lot of scripts running on your machine. But compiling the script every time you want to run it makes no sense at all as it completely negates the speed benefit.

## The solution
This project aims to be a tiny little program to solve the problem of using Nim for scripting. It takes the file passed to it through the shebang, with this file it establishes a nimcache directory in temporary storage, and compiles the script to a hidden file next to the script itself. On subsequent runs it checks if the script file is younger than the executable (ie. been edited after the last compilation) in which case it will compile it again, reusing the same nimcache directory if it exists. This means that the very first run of a script will do the entire compilation process, subsequent runs without changes will only run the executable, and runs where the source is newer than the executable will do the compilation process but use the old nimcache. The sum of this is a great speed-benefit without losing any of the flexibility often associated with scripts in general. Simply mark the script as executable and run it!

## A note on output
To make the output of a script as uniform as possible in order for it to be easily pipe to other processes this program will hide compilation output. As long as the Nim compiler completes without errors only the output of the script will be written to the terminal. In the case of a compiler failure the entire Nim compilation output along with the executed command will be written to stderr. This program will then exit with the error code of the compiler.

## Passing options
Originally nimcr didn't support any options other than compile target (C, C++, JS, etc.) but support for this has now been added. When using options you are required to specify the compile target first, followed by any options you might want. So an example shebang for this would look like this `#!/usr/env/nimcr c --deadCodeElim:on`, note the initial `c` specifying the compile target.

In order for nimcr to work and be convenient some options are added however and will throw an error or give unwanted behaviour when combined with conflicting options. These options are: 
```
--colors:on --nimcache:<cache directory> -d:release --out:<hidden file>
```
