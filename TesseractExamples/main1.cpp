/**
 * @file   main1.cpp
 * @author Marek Rychlik <marek@cannonball.lan>
 * @date   Fri Feb 22 19:48:12 2019
 * 
 * @brief  This example illustrates the use of Tesseract API.
 * 
 * From the Wiki:
 *
 * If you want to restrict recognition to a sub-rectangle of the image
 * - call SetRectangle(left, top, width, height) after SetImage. Each
 * SetRectangle clears the recogntion results so multiple rectangles
 * can be recognized with the same image. E.g.
 *
 *         api->SetRectangle(30, 86, 590, 100);
 */


#include <tesseract/baseapi.h>
#include <leptonica/allheaders.h>

//const char LANGUAGE[] = "eng";
//const char LANGUAGE[] = "chi_sim";
const char LANGUAGE[] = "chi_tra";


bool ocr(const char *const language, const char* const imagePath, const char *outPath)
{
  printf("Doing %s\n", imagePath);
  char *outText;

  tesseract::TessBaseAPI *api = new tesseract::TessBaseAPI();
  // Initialize tesseract-ocr with English, without specifying tessdata path
  if (api->Init(NULL, language)) {
    fprintf(stderr, "Could not initialize tesseract.\n");
    return false;
  }

  // Open input image with leptonica library
  // Pix *image = pixRead("./images/Paragraph.tif");
  Pix *image = pixRead(imagePath);
  if(image == NULL) {
    fprintf(stderr, "Could not read image: %s\n", imagePath);
    api->End();
    return false;
  }

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
