TRAINING_SCRIPT=/home/marek/TESSERACT/tesseract/src/training/tesstrain.sh
LANGDATA_DIR=/home/marek/TESSERACT/langdata
TESSDATA_DIR=/home/marek/TESSERACT/tesseract/tessdata

# List of fonts to train on
MY_FONTS=(
    "Courier New Bold" \
    "Courier New Bold Italic" \
    "Courier New Italic" \
    "Courier New" \
    "Times New Roman, Bold" \
    "Times New Roman, Bold Italic" \
    "Times New Roman, Italic" \
    "Times New Roman," \
    "Georgia Bold" \
    "Georgia Italic" \
    "Georgia" \
    "Georgia Bold Italic" \
    "Trebuchet MS Bold" \
    "Trebuchet MS Bold Italic" \
    "Trebuchet MS Italic" \
    "Trebuchet MS" \
    "Verdana Bold" \
    "Verdana Italic" \
    "Verdana" \
    "Verdana Bold Italic" \
    "URW Bookman L Bold" \
    "URW Bookman L Italic" \
    "URW Bookman L Bold Italic" \
    "Century Schoolbook L Bold" \
    "Century Schoolbook L Italic" \
    "Century Schoolbook L Bold Italic" \
    "Century Schoolbook L Medium" \
    "DejaVu Sans Ultra-Light" \
)



$TRAINING_SCRIPT --fonts_dir /usr/share/fonts --lang eng --linedata_only \
		 --fontlist  $MY_FONTS \
		 --noextract_font_properties --langdata_dir $LANGDATA_DIR \
		 --tessdata_dir  $TESSDATA_DIR --output_dir ~/tesstutorial/engtrain
