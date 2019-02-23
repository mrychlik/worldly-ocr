/**
 * @file   main3.cpp
 * @author Marek Rychlik <marek@cannonball.lan>
 * @date   Sat Feb 23 09:20:40 2019
 * 
 * @brief  
 * 
 * 
 */

#include <tesseract/baseapi.h>
#include <leptonica/allheaders.h>

bool ocr(const char *const language, const char* const imagePath, const char *outPath)
{
  printf("Doing %s\n", imagePath);
  char *outText;

  tesseract::TessBaseAPI *api = new tesseract::TessBaseAPI();
  // Initialize tesseract-ocr with English, without specifying tessdata path
  if (api->Init(NULL, language)) {
    fprintf(stderr, "Could not initialize tesseract.\n");
    exit(1);
  }

  // Open input image with leptonica library
  // Pix *image = pixRead("./images/Paragraph.tif");
  Pix *image = pixRead(imagePath);

  api->SetImage(image);
  // Get OCR result
  outText = api->GetUTF8Text();
    
  FILE *outFile;
  bool status = true;

  if((outFile = fopen(outPath,"w")) != NULL) {
    fprintf(outFile, "OCR output for image %s:\n%s", imagePath, outText);
    fclose(outFile);
  } else {
    status = false;
  }

  // Destroy used object and release memory
  api->End();
  delete [] outText;
  pixDestroy(&image);

  return status;
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
      "./images/Paragraph.tif",
      "./outputs/Paragraph.txt") || die();

  ocr("chi_tra",
      "./images/chinese-tradition-0pic.png",
      "./outputs/chinese-tradition-0pic-chi_tra.txt") || die();

  ocr("chi_sim",
      "./images/chinese-tradition-0pic.png",
      "./outputs/chinese-tradition-0pic-chi_sim.txt") || die();
}
