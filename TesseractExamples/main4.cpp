#include <tesseract/baseapi.h>
#include <leptonica/allheaders.h>


bool ocr(const char *const language, const char* const imagePath, const char *outPath)
{

  FILE *outFile;
  bool status = true;
  if((outFile = fopen(outPath,"w")) == NULL) {
    fprintf(stderr, "Could not open output file.\n");
    return false;
  }

  fprintf(outFile, "OCR output for image %s:\n", imagePath);


  tesseract::Orientation orientation;
  tesseract::WritingDirection direction;
  tesseract::TextlineOrder order;
  float deskew_angle;

  PIX *image = pixRead(imagePath);
  tesseract::TessBaseAPI *api = new tesseract::TessBaseAPI();
  api->Init("/usr/src/tesseract/", "eng");
  api->SetPageSegMode(tesseract::PSM_AUTO_OSD);
  api->SetImage(image);
  api->Recognize(0);

  tesseract::PageIterator* it =  api->AnalyseLayout();
  it->Orientation(&orientation, &direction, &order, &deskew_angle);
  fprintf(outFile, "Orientation: %d;\nWritingDirection: %d\nTextlineOrder: %d\n" \
	  "Deskew angle: %.4f\n",
	  orientation, direction, order, deskew_angle);

  return true;
}
