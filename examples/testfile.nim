#!nimcr "c --deadCodeElim:on --"
echo "Hello World!"

import os

let args =  commandLineParams()
echo args
