/**
 * @file   main4.cpp
 * @author Marek Rychlik <marek@cannonball.lan>
 * @date   Sat Feb 23 09:45:11 2019
 * 
 * @brief  Detect orientation, direction, deskew angle, line order
 * 
 * Explanation for result codes are in publictypes.h
 * NOTE: On some examples, "LEAK" error message results.
 */


#include <tesseract/baseapi.h>
#include <leptonica/allheaders.h>


bool ocr(const char *const language, const char* const imagePath, const char *outPath)
{
  printf("Doing %s\n", imagePath);

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
  api->Init("/usr/share/tesseract/", language);
  // api->Init(NULL, language);
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

int die()
{
  printf("Dead!!!");
  exit(EXIT_FAILURE);
}



int main()
{
  // Open input image with leptonica library
  ocr("eng",
      "./images/phototest.tif",
      "./outputs/phototest_osd.txt") || die();

  ocr("eng",
      "./images/Paragraph.tif",
      "./outputs/Paragraph_osd.txt") || die();

  ocr("chi_tra",
      "./images/chinese-tradition-0pic.png",
      "./outputs/chinese-tradition-0pic-chi_tra_osd.txt") || die();

  ocr("chi_sim",
      "./images/chinese-tradition-0pic.png",
      "./outputs/chinese-tradition-0pic-chi_sim_osd.txt") || die();
}
