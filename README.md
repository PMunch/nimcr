# Running Nim code with Shebangs
Shebangs are a tiny comment at the beginning of a file that tells the operating system what program can be used to run the contents of that file. It is typically seen in bash scripts starting with `#!/bin/bash` or in Python scripts as `#!/usr/bin/env python`. Nim however is not an interpreted language, this means that having a program that "runs" Nim files would actually mean compile and run. This was outlined in issue [#66](https://github.com/nim-lang/Nim/issues/66) for Nim but was closed after Araq showed how it could be achieved with flags to the compiler. However this solution is a bit lacking. Nim, being a compiled language, offers a speed benefit over many other languages. So writing scripts in Nim makes sense if you want to have a lot of scripts running on your machine. But compiling the script every time you want to run it makes no sense at all as it completely negates the speed benefit.

## The solution
This project aims to be a tiny little program to solve the problem of using Nim for scripting. It takes the file passed to it through the shebang and establishes a nimcache directory in temporary storage, then it compiles the script to a hidden file next to the script itself. On subsequent runs it checks if the script file is newer than the executable (ie. been edited after the last compilation) in which case it will compile it again, reusing the same nimcache directory if it exists. This means that the very first run of a script will do the entire compilation process, subsequent runs without changes will only run the executable, and runs where the source is newer than the executable will do the compilation process but use the old nimcache. The sum of this is a great speed-benefit without losing any of the flexibility often associated with scripts in general. Simply mark the script as executable and run it!

## A note on output
To make the output of a script as uniform as possible in order for it to easily pipe to other processes this program will hide the compilation output. As long as the Nim compiler completes without errors only the output of the script will be written to the terminal. In the case of a compiler failure the entire Nim compilation output along with the executed command will be written to stderr. This program will then exit with the error code of the compiler.

## How to compile/run your script using nimcr
Make the first line in your nim script read as follows: `#!/usr/bin/env nimcr` and optionally make the script executable.

## Passing options
**WARNING** since version 1.0.0 the syntax for passing command line options has changed in an non-backwards compatible manner. This was necessary in order to support passing options to the nim compiler as well as the actual script in a way that works across different platforms supporting shebangs.

Command line options can be specified for the nim compiler and for the actual script.

### Options for the script
Options for the script are passed on the command line as you would with any other program, like so:

``` bash
# Example 1: do not pass command line switches nor arguments for the script
$ ./script-using-nimcr
# Example 2: path both command line switches and arguments
$ ./script-using-nimcr -option1 -option2 positional_arg1 positional_arg2
```

The script will be able to access command line switches and arguments as any other nim program.

### Options for the nim compiler
Options for the nim compiler can be specified by adding a specially formatted comment as second line of the script starting with `#nimcr-args` followed by a space then followed by command line switches and arguments to the nim compiler.

``` bash
#!/usr/bin/env nimcr
#nimcr-args c --opt:size

... rest of the script
```

If `#nimcr-args` is not present as second line of the script it defaults to `c -d:release`.

### Options automatically appended by nimcr
In order for nimcr to work and be convenient, some options are added to the execution and will throw an error or give unwanted behaviour when combined with conflicting options. These options are:
```
--colors:on --nimcache:<cache directory> --out:<hidden file>
```
