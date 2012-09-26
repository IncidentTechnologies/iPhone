#!/bin/sh

perl headerdoc/headerDoc2HTML.pl ../GtarController/GtarController.h -o .
perl headerdoc/headerDoc2HTML.pl ../Gtar.h -o .

perl headerdoc/gatherHeaderDoc.pl .