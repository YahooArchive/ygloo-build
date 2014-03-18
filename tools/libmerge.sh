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

echo -ne '!<arch>\n' > $OUT
while (( "$#" )); do
  echo "  -> $1"
  tail -c +9 "$1" >> "$OUT"
  shift
done

if [ "$RUN_RANLIB" = "true" ]; then
  ranlib "$OUT"
fi

