#!/bin/sh

if [ -z "$ASN1C" ]; then
	ASN1C="asn1c"
fi

die() {
	echo "$1"
	exit 1
}

OUTPUT_DIR=libasn1fort

rm -fr $OUTPUT_DIR || die "Could not delete directory $OUTPUT_DIR."
mkdir -p $OUTPUT_DIR || die "Could not create directory '$OUTPUT_DIR'."

"$ASN1C" -Werror -fcompound-names -fwide-types -D $OUTPUT_DIR \
		-no-gen-PER -no-gen-example \
		asn1/*.asn1 || die "Compilation failed."

# Replace '#include <file.h>' with '#include <$OUTPUT_DIR/file.h>' everywhere.
sed -Ei "" 's!#include [<"](.*)\.h[">]!#include <libasn1fort/\1.h>!' \
	$OUTPUT_DIR/*.c $OUTPUT_DIR/*.h

# Restore the system includes.
SYSTEM_INCLUDES="assert|errno|float|inttypes|limits|malloc|netinet/in|stdarg|stddef|stdint|stdio|stdlib|string|sys/types|time|types/vxTypes|windows"
sed -Ei "" "s!#include <libasn1fort/($SYSTEM_INCLUDES)\.h>!#include <\1.h>!" \
	$OUTPUT_DIR/*.c $OUTPUT_DIR/*.h

# Change the default name of the library
sed -i '' 's/libasncodec/libasn1fort/' libasn1fort/Makefile.am.libasncodec
