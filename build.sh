#!/bin/bash

cd "$( dirname "${BASH_SOURCE[0]}" )" || exit
RAWSVGS_BASE="src/base/svgs"
INDEX_BASE="src/base/cursor.theme"
RAWSVGS_RED="src/red/svgs"
INDEX_RED="src/red/cursor.theme"
ALIASES="src/cursorList"


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
mkdir -p "$DIR2X_RED"
mkdir -p "$DIR1X_RED"
mkdir -p "$DIR2X_BASE"
mkdir -p "$DIR1X_BASE"
mkdir -p "$OUTPUT_BASE/cursors"
mkdir -p "$OUTPUT_RED/cursors"
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
done < $ALIASES
echo -e "\\033[0KGenerating shortcuts... DONE"


echo -ne "Copying Theme Index...\\r"
    if ! [ -e "$OUTPUT_BASE/$INDEX_BASE" ] ; then
        cp $INDEX_BASE "$OUTPUT_BASE/cursor.theme"
    fi
    if ! [ -e "$OUTPUT_RED/$INDEX_RED" ] ; then
        cp $INDEX_RED "$OUTPUT_RED/cursor.theme"
    fi
echo -e "\\033[0KCopying Theme Index... DONE"


echo "COMPLETE!"
