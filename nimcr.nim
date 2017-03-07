import os, osproc
import hashes, strutils

# Handle command line parameters
let args =  commandLineParams()

if args.len == 0 or args.len > 2:
  stderr.write "Usage: nimcr filename [compile target, default 'c']"
  quit -1
  
let
  filename = args[args.high].expandFilename
  compTarget =
    if args.len == 2:
      args[0]
    else:
      "c"

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
if not exeName.existsFile or filename.fileNewer exeName:
  exeName.removeFile
  (output, buildStatus) = execCmdEx("nim " & compTarget & " --colors:on --nimcache:" & getTempDir()/("nimcache-" & filename.hash.toHex) & " --out:\"" & exeName & "\" " & filename)
  # Windows file hiding (hopefully, not tested)
  when defined(windows):
    execShellCmd("attrib +H " & exeName)

# Run the target, or show an error
if buildStatus == 0:
  quit execShellCmd(exeName)
else:
  stderr.write output
  quit buildStatus