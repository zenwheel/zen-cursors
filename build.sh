#!/bin/bash

cd "$( dirname "${BASH_SOURCE[0]}" )" || exit
RAWSVGS="src/zen/svgs"
INDEX="src/zen/cursor.theme"
ALIASES="src/cursorList"


echo -ne "Checking Requirements...\\r"
if [ ! -f $INDEX ] ; then
    echo -e "\\nFAIL: '$INDEX' missing"
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
DIR2X="build/zen/x2"
DIR1X="build/zen/x1"
OUTPUT="$(grep --only-matching --perl-regex "(?<=Name\\=).*$" $INDEX)"
OUTPUT=${OUTPUT// /_}
mkdir -p "$DIR2X"
mkdir -p "$DIR1X"
mkdir -p "$OUTPUT/cursors"
echo 'Making Folders... DONE';


for CUR in src/config/*.cursor; do
    BASENAME=$CUR
    BASENAME=${BASENAME##*/}
    BASENAME=${BASENAME%.*}

    echo -ne "\\033[0KGenerating simple cursor pixmaps... $BASENAME\\r"

    inkscape -w 32  -f $RAWSVGS/"$BASENAME".svg -e "$DIR1X/$BASENAME.png" > /dev/null
    inkscape -w 64 -f $RAWSVGS/"$BASENAME".svg -e "$DIR2X/$BASENAME.png" > /dev/null
done
echo -e "\\033[0KGenerating simple cursor pixmaps... DONE"


for i in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24
do
    echo -ne "\\033[0KGenerating animated cursor pixmaps... $i / 24 \\r"

    inkscape -w 32  -f $RAWSVGS/progress-$i.svg -e "$DIR1X/progress-$i.png" > /dev/null
    inkscape -w 64 -f $RAWSVGS/progress-$i.svg -e "$DIR2X/progress-$i.png" > /dev/null

    inkscape -w 32  -f $RAWSVGS/wait-$i.svg -e "$DIR1X/wait-$i.png" > /dev/null
    inkscape -w 64 -f $RAWSVGS/wait-$i.svg -e "$DIR2X/wait-$i.png" > /dev/null
done
echo -e "\\033[0KGenerating animated cursor pixmaps... DONE"


echo -ne "Generating cursor theme...\\r"
for CUR in src/config/*.cursor; do
    BASENAME=$CUR
    BASENAME=${BASENAME##*/}
    BASENAME=${BASENAME%.*}

    if ! ERR="$( xcursorgen -p build/zen "$CUR" "$OUTPUT/cursors/$BASENAME" 2>&1 )"; then
        echo "FAIL: $CUR $ERR"
    fi
done
echo -e "Generating cursor theme... DONE"


echo -ne "Generating shortcuts...\\r"
while read -r ALIAS ; do
    FROM=${ALIAS% *}
    TO=${ALIAS#* }
    if [ -e "$OUTPUT/cursors/$FROM" ] ; then
        continue
    fi
    ln -sf "$TO" "$OUTPUT/cursors/$FROM"
done < $ALIASES
echo -e "\\033[0KGenerating shortcuts... DONE"


echo -ne "Copying Theme Index...\\r"
    if ! [ -e "$OUTPUT/$INDEX" ] ; then
        cp $INDEX "$OUTPUT/cursor.theme"
    fi
echo -e "\\033[0KCopying Theme Index... DONE"


echo "COMPLETE!"
