# From Tesseract Wiki

# Making Box Files

As with base Tesseract, there is a choice between rendering synthetic
training data from fonts, or labeling some pre-existing images (like
ancient manuscripts for example).

In either case, the required format is still the tiff/box file pair, except that the boxes only need to cover a textline instead of individual characters.

Each line in the box file matches a 'character' (glyph) in the tiff image.

<symbol> <left> <bottom> <right> <top> <page>

To mark an end-of-textline, a special line must be inserted after a series of lines.

<tab> <left> <bottom> <right> <top> <page>

Note that in all cases, even for right-to-left languages, such as
Arabic, the text transcription for the line, should be ordered
left-to-right. In other words, the network is going to learn from
left-to-right regardless of the language, and the right-to-left/bidi
handling happens at a higher level inside Tesseract.