import os, osproc
import hashes, strutils

# Inspect command line parameters
let args =  commandLineParams()

if args.len == 0:
  stderr.write "Usage on the command line: nimcr filename [arguments to program]\n"
  stderr.write "Usage in a script:\n"
  stderr.write "\t1- add `#!/usr/bin/env nimcr` to your script as first line\n"
  stderr.write "\t2- (optional) add `#nimcr-args [arguments for nim compiler]` to your script as second line\n"
  quit -1

var filenamePos = args.low
let filename = args[filenamePos].expandFilename

# Split the file path and make a new one which is a hidden file on Linux, Windows file hiding comes later
let
  splitName = filename.splitfile
  ext =
    when defined(windows):
      ".exe"
    else:
      ""
  exeName = splitName.dir/("." & splitName.name & ext)

# Compilation of script if target doesn't exist
var
  buildStatus = 0
  output = ""
  command = ""

if not exeName.existsFile or filename.fileNewer exeName:
  var nimArgs: string = "c -d:release"
  # Get extra arguments for nim compiler from the second line (it must start with #nimcr-args [args] )
  block:
    let scriptfile = open(filename)
    defer: scriptfile.close()
    discard scriptfile.readLine()
    var secondLine = scriptfile.readLine()
    if secondLine.startsWith("#nimcr-args "):
      secondLine.removePrefix("#nimcr-args ")
      nimArgs = secondLine

  exeName.removeFile
  command = "nim " & nimArgs & " --colors:on --nimcache:" &
    getTempDir()/("nimcache-" & filename.hash.toHex) &
    " --out:\"" & exeName & "\" " & filename

  (output, buildStatus) = execCmdEx(command)
  # Windows file hiding (hopefully, not tested)
  when defined(windows):
    execShellCmd("attrib +H " & exeName)

# Run the target, or show an error
if buildStatus == 0:
  let p = startProcess(exeName,  args=args[args.low+1 .. ^1],
                       options={poStdErrToStdOut, poParentStreams, poUsePath})
  let res = p.waitForExit()
  p.close()
  quit res
else:
  stderr.write "(nimcr) Error on build running command: " & command
  stderr.write output
  quit buildStatus
