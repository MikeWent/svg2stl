#!/bin/bash
set -e

if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
    echo "need three arguments: input.svg output.stl [-1]"
    exit
fi

# script params.
INPUT_SVG_PATH=/data/$1
OUTPUT_STL_PATH=/data/$2
NEGATIVE=$3

# preserve original svg size.
svg_width=$(xmllint --xpath "string(/*[local-name()='svg']/@width)" "$INPUT_SVG_PATH")
svg_height=$(xmllint --xpath "string(/*[local-name()='svg']/@height)" "$INPUT_SVG_PATH")
echo "input svg size: $svg_width x $svg_height"

# svg files from kicad cannot be reliably imported into openscad.
# the simplest way to fix it is to rasterize the image and convert it to vector again.
echo -n "converting input SVG to bitmap... "
# intermidiate bitmap size, larger = better rasterization, but slower.
DPI=2000
if [[ "$NEGATIVE" -eq "-1" ]]; then
    im_params="-channel rgb -negate"
else
    im_params=""
fi
convert -density $DPI "$INPUT_SVG_PATH" $im_params bitmap.bmp
echo "OK"

echo -n "converting bitmap back to SVG... "
potrace \
    --backend svg \
    --resolution $DPI \
    --width "$svg_width" \
    --height "$svg_height" \
    --output openscad.svg \
    bitmap.bmp
echo "OK"

echo -n "rendering STL... "
openscad -o "$OUTPUT_STL_PATH" svg2stl.scad
echo "OK"

echo "done! $2"
