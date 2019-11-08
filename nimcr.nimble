# Package

version       = "0.3.0"
author        = "Peter Munch-Ellingsen"
description   = "Simple program that allows you to use the shebang #!nimcr in your Nim files. It will automatically compile the file to a hidden executable in the same directory as the nim file as long as the file doesn\'t already exist and is younger than (ie. created after the last modification of) the script file. If it is younger it will simply run the executable saving you from compiling the script each time it is run. The output of the compiler is also ignored if the compilation is succesfull and only the output of the program is used. If the compilation fails the output will be written to stderr and the return code will match that of the compiler."
license       = "MIT"

# Dependencies

requires "nim >= 0.16.0"


# Examples

skipDirs = @["examples"]

# Binary package

bin = @["nimcr"]
skipExt = @["nim"]
