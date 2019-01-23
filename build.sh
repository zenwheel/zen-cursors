#!/bin/bash

cd "$( dirname "${BASH_SOURCE[0]}" )" || exit
RAWSVGS_BASE="src/base/svgs"
INDEX_BASE="src/base/cursor.theme"
RAWSVGS_RED="src/red/svgs"
INDEX_RED="src/red/cursor.theme"
ALIASES="src/cursorList"
INDEX_SHADOW="src/shadow/cursor.theme"
INDEX_SHADOW_RED="src/shadow-red/cursor.theme"


echo -ne "Checking Requirements...\\r"
if [ ! -f $INDEX_BASE ] ; then
    echo -e "\\nFAIL: '$INDEX_BASE' missing"
    exit 1
elif [ ! -f $INDEX_RED ] ; then
    echo -e "\\nFAIL: '$INDEX_RED' missing"
    exit 1
elif ! type "inkscape" > /dev/null ; then
    echo -e "\\nFAIL: inkscape must be installed"
    exit 1
elif ! type "xcursorgen" > /dev/null ; then
    echo -e "\\nFAIL: xcursorgen must be installed"
    exit 1
fi
echo -e "Checking Requirements... DONE"


echo -ne "Making Folders... $BASENAME\\r"
DIR2X_BASE="build/base/x2"
DIR1X_BASE="build/base/x1"
DIR2X_RED="build/red/x2"
DIR1X_RED="build/red/x1"
OUTPUT_BASE="$(grep --only-matching --perl-regex "(?<=Name\\=).*$" $INDEX_BASE)"
OUTPUT_BASE=${OUTPUT_BASE// /_}
OUTPUT_RED="$(grep --only-matching --perl-regex "(?<=Name\\=).*$" $INDEX_RED)"
OUTPUT_RED=${OUTPUT_RED// /_}
OUTPUT_SHADOW="$(grep --only-matching --perl-regex "(?<=Name\\=).*$" $INDEX_SHADOW)"
OUTPUT_SHADOW=${OUTPUT_SHADOW// /_}
OUTPUT_SHADOW_RED="$(grep --only-matching --perl-regex "(?<=Name\\=).*$" $INDEX_SHADOW_RED)"
OUTPUT_SHADOW_RED=${OUTPUT_SHADOW_RED// /_}
mkdir -p "$DIR2X_RED"
mkdir -p "$DIR1X_RED"
mkdir -p "$DIR2X_BASE"
mkdir -p "$DIR1X_BASE"
mkdir -p "$OUTPUT_BASE/cursors"
mkdir -p "$OUTPUT_RED/cursors"
mkdir -p "$OUTPUT_SHADOW/cursors"
mkdir -p "$OUTPUT_SHADOW_RED/cursors"
for size in x1 x2; do
	mkdir -p build/shadow/$size
	mkdir -p build/shadow-red/$size
done
echo 'Making Folders... DONE';


for CUR in src/config/*.cursor; do
    BASENAME=$CUR
    BASENAME=${BASENAME##*/}
    BASENAME=${BASENAME%.*}

    echo -ne "\\033[0KGenerating simple cursor pixmaps... $BASENAME\\r"

    inkscape -w 32  -f $RAWSVGS_BASE/"$BASENAME".svg -e "$DIR1X_BASE/$BASENAME.png" >& /dev/null
    inkscape -w 64 -f $RAWSVGS_BASE/"$BASENAME".svg -e "$DIR2X_BASE/$BASENAME.png" >& /dev/null
    inkscape -w 32  -f $RAWSVGS_RED/"$BASENAME".svg -e "$DIR1X_RED/$BASENAME.png" >& /dev/null
    inkscape -w 64 -f $RAWSVGS_RED/"$BASENAME".svg -e "$DIR2X_RED/$BASENAME.png" >& /dev/null
done
echo -e "\\033[0KGenerating simple cursor pixmaps... DONE"


for i in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24
do
    echo -ne "\\033[0KGenerating animated cursor pixmaps... $i / 24 \\r"

    inkscape -w 32  -f $RAWSVGS_BASE/progress-$i.svg -e "$DIR1X_BASE/progress-$i.png" >& /dev/null
    inkscape -w 64 -f $RAWSVGS_BASE/progress-$i.svg -e "$DIR2X_BASE/progress-$i.png" >& /dev/null
    inkscape -w 32  -f $RAWSVGS_RED/progress-$i.svg -e "$DIR1X_RED/progress-$i.png" >& /dev/null
    inkscape -w 64 -f $RAWSVGS_RED/progress-$i.svg -e "$DIR2X_RED/progress-$i.png" >& /dev/null

    inkscape -w 32  -f $RAWSVGS_BASE/wait-$i.svg -e "$DIR1X_BASE/wait-$i.png" >& /dev/null
    inkscape -w 64 -f $RAWSVGS_BASE/wait-$i.svg -e "$DIR2X_BASE/wait-$i.png" >& /dev/null
    inkscape -w 32  -f $RAWSVGS_RED/wait-$i.svg -e "$DIR1X_RED/wait-$i.png" >& /dev/null
    inkscape -w 64 -f $RAWSVGS_RED/wait-$i.svg -e "$DIR2X_RED/wait-$i.png" >& /dev/null
done
echo -e "\\033[0KGenerating animated cursor pixmaps... DONE"

# copy base icons that aren't overridden to sub-theme
cp -n "$DIR1X_BASE"/*.png "$DIR1X_RED/"
cp -n "$DIR2X_BASE"/*.png "$DIR2X_RED/"


echo -ne "Creating shadow variants...\\r"
for style in base red; do
	OUT=build/shadow
	if [ $style = "red" ]; then
		OUT=build/shadow-red
	fi
	for size in x1 x2; do
		OFFSET=3
		BLUR_SIZE=3
		if [ $size = "x2" ]; then
			OFFSET=5
			BLUR_SIZE=5
		fi

		for f in build/$style/$size/*; do
			BASENAME=$f
			BASENAME=${BASENAME##*/}
			echo -ne "\\033[0KCreating shadow variants... $style/$BASENAME\\r"
			ORIGINAL_SIZE=$(identify -format '%wx%h' $f)
			ORIGINAL_WIDTH=$(echo $ORIGINAL_SIZE | cut -d x -f 1)
			ORIGINAL_HEIGHT=$(echo $ORIGINAL_SIZE | cut -d x -f 2)
			EXTENT_WIDTH=$(expr $ORIGINAL_WIDTH + $BLUR_SIZE)
			EXTENT_HEIGHT=$(expr $ORIGINAL_HEIGHT + $BLUR_SIZE + $OFFSET)
			echo -ne "\\033[0KCreating shadow variants... $style/$BASENAME\\r"

			convert "$f" \
-background none -extent ${EXTENT_WIDTH}x$EXTENT_HEIGHT \
'(' \
	+clone \
	-alpha extract -blur 0x2 -background black -alpha Shape \
	-geometry +0+$OFFSET \
	-matte -channel A +level 0,50% +channel \
')' \
-compose DstOver -composite \
"$OUT/$size/$BASENAME"
		done
	done
done

echo -e "\\033[0KCreating shadow variants... DONE";



echo -ne "Generating cursor theme...\\r"
for CUR in src/config/*.cursor; do
    BASENAME=$CUR
    BASENAME=${BASENAME##*/}
    BASENAME=${BASENAME%.*}

    if ! ERR="$( xcursorgen -p build/base "$CUR" "$OUTPUT_BASE/cursors/$BASENAME" 2>&1 )"; then
        echo "FAIL: $CUR $ERR"
    fi

    if ! ERR="$( xcursorgen -p build/red "$CUR" "$OUTPUT_RED/cursors/$BASENAME" 2>&1 )"; then
        echo "FAIL: $CUR $ERR"
    fi

    if ! ERR="$( xcursorgen -p build/shadow "$CUR" "$OUTPUT_SHADOW/cursors/$BASENAME" 2>&1 )"; then
        echo "FAIL: $CUR $ERR"
    fi

    if ! ERR="$( xcursorgen -p build/shadow-red "$CUR" "$OUTPUT_SHADOW_RED/cursors/$BASENAME" 2>&1 )"; then
        echo "FAIL: $CUR $ERR"
    fi
done
echo -e "Generating cursor theme... DONE"


echo -ne "Generating shortcuts...\\r"
while read -r ALIAS ; do
    FROM=${ALIAS% *}
    TO=${ALIAS#* }
    if [ -e "$OUTPUT_BASE/cursors/$FROM" ] ; then
        continue
    fi
    ln -sf "$TO" "$OUTPUT_BASE/cursors/$FROM"

    if [ -e "$OUTPUT_RED/cursors/$FROM" ] ; then
        continue
    fi
    ln -sf "$TO" "$OUTPUT_RED/cursors/$FROM"

    if [ -e "$OUTPUT_SHADOW/cursors/$FROM" ] ; then
        continue
    fi
    ln -sf "$TO" "$OUTPUT_SHADOW/cursors/$FROM"

    if [ -e "$OUTPUT_SHADOW_RED/cursors/$FROM" ] ; then
        continue
    fi
    ln -sf "$TO" "$OUTPUT_SHADOW_RED/cursors/$FROM"
done < $ALIASES
echo -e "\\033[0KGenerating shortcuts... DONE"


echo -ne "Copying Theme Index...\\r"
    if ! [ -e "$OUTPUT_BASE/$INDEX_BASE" ] ; then
        cp $INDEX_BASE "$OUTPUT_BASE/cursor.theme"
    fi
    if ! [ -e "$OUTPUT_RED/$INDEX_RED" ] ; then
        cp $INDEX_RED "$OUTPUT_RED/cursor.theme"
    fi
    if ! [ -e "$OUTPUT_SHADOW/$INDEX_SHADOW" ] ; then
        cp $INDEX_SHADOW "$OUTPUT_SHADOW/cursor.theme"
    fi
    if ! [ -e "$OUTPUT_SHADOW_RED/$INDEX_SHADOW_RED" ] ; then
        cp $INDEX_SHADOW_RED "$OUTPUT_SHADOW_RED/cursor.theme"
    fi
echo -e "\\033[0KCopying Theme Index... DONE"

echo -ne "Creating archives...\\r"
for variant in $OUTPUT_BASE $OUTPUT_RED $OUTPUT_SHADOW $OUTPUT_SHADOW_RED; do
	echo -ne "\\033[0KCreating archives... $variant\\r"
	tar czf "$variant.tar.gz" "$variant"
done
echo -e "\\033[0KCreating archives... DONE"

echo "COMPLETE!"
