/**
 * @file   main2.cpp
 * @author Marek Rychlik <marek@cannonball.lan>
 * @date   Sat Feb 23 09:03:03 2019
 * 
 * @brief  This example calls GetComponentImages
 * 
 * 
 */

#include <tesseract/baseapi.h>
#include <leptonica/allheaders.h>


bool ocr(const char *const language, const char* const imagePath, const char *outPath)
{
  bool status = true;

  Pix *image = pixRead(imagePath);
  if(image == NULL) {
    fprintf(stderr, "Could not read image: %s\n", imagePath);
    return false;
  }

  tesseract::TessBaseAPI *api = new tesseract::TessBaseAPI();
  if(api->Init(NULL, language)) {
    fprintf(stderr, "Could not initialize tesseract.\n");
    return false;
  }

  api->SetImage(image);
  Boxa* boxes = api->GetComponentImages(tesseract::RIL_TEXTLINE, true, NULL, NULL);
  printf("Found %d textline image components.\n", boxes->n);

  FILE *outFile;
  if((outFile = fopen(outPath,"w")) != NULL) {
    fprintf(outFile, "OCR output for image %s:\n", imagePath);
    for (int i = 0; i < boxes->n; i++) {
      BOX* box = boxaGetBox(boxes, i, L_CLONE);
      api->SetRectangle(box->x, box->y, box->w, box->h);
      char* ocrResult = api->GetUTF8Text();
      int conf = api->MeanTextConf();
      fprintf(outFile, "Box[%d]: x=%d, y=%d, w=%d, h=%d, confidence: %d, text: %s",
	      i, box->x, box->y, box->w, box->h, conf, ocrResult);
    }

    fclose(outFile);
  } else {
    status = false;
  }

  api->End();
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
      "./images/phototest.tif",
      "./outputs/phototest_components.txt") || die();

  ocr("eng",
      "./images/Paragraph.tif",
      "./outputs/Paragraph_components.txt") || die();

  ocr("chi_tra",
      "./images/chinese-tradition-0pic.png",
      "./outputs/chinese-tradition-0pic-chi_tra_components.txt") || die();

  ocr("chi_sim",
      "./images/chinese-tradition-0pic.png",
      "./outputs/chinese-tradition-0pic-chi_sim_components.txt") || die();
}

