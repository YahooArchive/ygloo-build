#!/bin/bash

USAGE="Usage: $0 ?-static? ?-o libout.a? lib1.a lib2.a ..."
if [ "$#" == "0" ]; then
	echo "$USAGE"
	exit 1
fi

RUN_RANLIB="false"

if [ "$1" = "-static" ]; then
  shift
fi

if [ "$1" = "-o" ]; then
  shift
  OUT="$1"
  shift
fi

if [ "$OUT" = "" ]; then
  echo "no output file specified"
  exit 1
fi

echo "Generating library $OUT"

if [ "$AR" = "" ]; then
  AR=ar
fi
if [ "$RANLIB" = "" ]; then
  RANLIB=ranlib
fi

# Is it a GNU implementation of ar
GNUAR=true

# Use GNU ar to generate merged library
if [ "$GNUAR" = true ]; then
  OUTSCRIPT="${OUT}.mri"
  echo "create ${OUT}" > "$OUTSCRIPT"
  while (( "$#" )); do
    echo "addlib $1" >> "$OUTSCRIPT"
    shift
  done
  echo "save" >> "$OUTSCRIPT"
  echo "end" >> "$OUTSCRIPT"
  "$AR" -M < "$OUTSCRIPT"
else
  echo -ne '!<arch>\n' > $OUT
  while (( "$#" )); do
    echo "  -> $1"
    tail -c +9 "$1" >> "$OUT"
    shift
  done
fi

if [ "$RUN_RANLIB" = "true" ]; then
  "$RANLIB" "$OUT"
fi

