#!/bin/sh

perl headerdoc/headerDoc2HTML.pl ../GtarController/GtarController/GtarController.h -o ./Documents
perl headerdoc/headerDoc2HTML.pl ../Gtar.h -o ./Documents

perl headerdoc/gatherHeaderDoc.pl ./Documents