import os, osproc
import hashes, strutils

# Inspect command line parameters
let args =  commandLineParams()

if args.len == 0:
  stderr.write "Usage: nimcr [compile target, default 'c' [options] --] filename [arguments to program]\n"
  quit -1

var filenamePos = args.high
for i in 0..args.high:
  # Linux passes all args in as a single string, BSD  splits it into multiple arguments
  let arguments = if args[i][0] == '"' and args[i][^1] == '"': args[i][1..^2] else: args[i]
  if arguments == "--" or arguments.strip().endsWith(" --"):
    filenamePos = i + 1
    break

let
  filename = args[filenamePos].expandFilename

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
  # Get any extra arguments from the command and compile
  var
    splittingArg = if filenamePos > 0:
      if args[filenamePos - 1][0] == '"' and args[filenamePos - 1][^1] == '"':
        args[filenamePos - 1][1..^2].strip()
      else:
        args[filenamePos - 1].strip()
    else: ""
  splittingArg.removeSuffix(" --")
  if splittingArg == "--": splittingArg = ""
  let extraArgs =
    if filenamePos > 0:
      args[0..filenamePos-2].join(" ") & " " & splittingArg
    else:
      "c"

  exeName.removeFile
  command = "nim " & extraArgs & " --colors:on --nimcache:" &
    getTempDir()/("nimcache-" & filename.hash.toHex) &
    " -d:release --out:\"" & exeName & "\" " & filename

  (output, buildStatus) = execCmdEx(command)
  # Windows file hiding (hopefully, not tested)
  when defined(windows):
    execShellCmd("attrib +H " & exeName)

# Run the target, or show an error
if buildStatus == 0:
  quit execShellCmd(exeName & " " & args[filenamePos + 1 .. ^1].join(" "))
else:
  stderr.write "(nimcr) Error on build running command: " & command
  stderr.write output
  quit buildStatus
