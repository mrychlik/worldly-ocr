!/bin/bash
# We train with some Windows fonts
FONTDIR=/home/marek/.wine/drive_c/windows/Fonts

# Where is my tesseract installation; certain paths are
# specified relative to this directory
TESSERACT_HOME=/home/marek/TESSERACT/tesseract

cd $TESSERACT_HOME

LANGDATA_DIR='../langdata'
TESSDATA_DIR='/usr/share/tesseract/tessdata'



# List of fonts to train on
MYFONTS=(
    "Arial"
    "Verdana"
)





./src/training/tesstrain.sh --fonts_dir $FONTDIR --lang eng --linedata_only \
		 --fontlist $MYFONTS \
		 --noextract_font_properties --langdata_dir $LANGDATA_DIR \
		 --tessdata_dir  $TESSDATA_DIR --output_dir ~/tesstutorial/engtrain
