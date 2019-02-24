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

  Pix *image = pixRead(imagePath);

  if(image == NULL) {
    fprintf(stderr, "Could not read image: %s\n", imagePath);
    return false;
  }

  tesseract::TessBaseAPI *api = new tesseract::TessBaseAPI();


  // Initialize tesseract-ocr with language, without specifying tessdata path
  if (api->Init(NULL, language)) {
    fprintf(stderr, "Could not initialize tesseract.\n");
    return false;
  }

  FILE *outFile;
  bool status = true;
  if((outFile = fopen(outPath,"w")) == NULL) {
    fprintf(stderr, "Could not open output file.\n");
    return false;
  }

  fprintf(outFile, "OCR output for image %s:\n", imagePath);


  api->Init(NULL, language);
  api->SetImage(image);
  api->Recognize(0);

  tesseract::ResultIterator* ri = api->GetIterator();
  tesseract::PageIteratorLevel level = tesseract::RIL_WORD;
  if (ri != 0) {
    do {
      const char* word = ri->GetUTF8Text(level);
      float conf = ri->Confidence(level);
      int x1, y1, x2, y2;
      ri->BoundingBox(level, &x1, &y1, &x2, &y2);
      fprintf(outFile, "word: '%s';  \tconf: %.2f; BoundingBox: %d,%d,%d,%d;\n",
	      word, conf, x1, y1, x2, y2);
      delete[] word;
    } while (ri->Next(level));
  }

  fclose(outFile);

  // Destroy used object and release memory
  api->End();
  pixDestroy(&image);

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
      "./outputs/phototest_boxes.txt") || die();

  ocr("eng",
      "./images/Paragraph.tif",
      "./outputs/Paragraph_boxes.txt") || die();

  ocr("chi_tra",
      "./images/chinese-tradition-0pic.png",
      "./outputs/chinese-tradition-0pic-chi_tra_boxes.txt") || die();

  ocr("chi_sim",
      "./images/chinese-tradition-0pic.png",
      "./outputs/chinese-tradition-0pic-chi_sim_boxes.txt") || die();
}
