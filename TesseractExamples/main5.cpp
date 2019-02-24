/**
 * @file   main5.cpp
 * @author Marek Rychlik <marek@cannonball.lan>
 * @date   Sat Feb 23 10:07:02 2019
 * 
 * @brief  Example of single symbol API.
 * 
 * NOTE: The API prints to stdout some spurious newlines somewhere.
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


  Pix *image = pixRead(imagePath);
  tesseract::TessBaseAPI *api = new tesseract::TessBaseAPI();
  api->Init(NULL, language);
  api->SetImage(image);
  api->SetVariable("save_blob_choices", "T");
  api->SetRectangle(37, 228, 548, 31);
  api->Recognize(NULL);

  tesseract::ResultIterator* ri = api->GetIterator();
  tesseract::PageIteratorLevel level = tesseract::RIL_SYMBOL;
  if(ri != 0) {
    do {
      const char* symbol = ri->GetUTF8Text(level);
      float conf = ri->Confidence(level);
      if(symbol != 0) {
	fprintf(outFile, "symbol %s, conf: %f", symbol, conf);
	bool indent = false;
	tesseract::ChoiceIterator ci(*ri);
	do {
	  if (indent) printf("\t\t ");
	  fprintf(outFile, "\t- ");
	  const char* choice = ci.GetUTF8Text();
	  fprintf(outFile, "%s conf: %f\n", choice, ci.Confidence());
	  indent = true;
	} while(ci.Next());
      }
      fprintf(outFile, "---------------------------------------------\n");
      delete[] symbol;
    } while((ri->Next(level)));
  }

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
      "./outputs/phototest_symbol.txt") || die();


  ocr("eng",
      "./images/Paragraph.tif",
      "./outputs/Paragraph_symbol.txt") || die();

  ocr("chi_tra",
      "./images/chinese-tradition-0pic.png",
      "./outputs/chinese-tradition-0pic-chi_tra_symbol.txt") || die();

  ocr("chi_sim",
      "./images/chinese-tradition-0pic.png",
      "./outputs/chinese-tradition-0pic-chi_sim_symbol.txt") || die();
}
