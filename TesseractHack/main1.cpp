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
 *
 *
 * In C++11/14 with the "Filesystem TS", the <experimental/filesystem>
 * header and range-for you can simply do this:
 *
 * #include <experimental/filesystem>

 * using std::experimental::filesystem::recursive_directory_iterator;
 * ...
 * for (auto& dirEntry : recursive_directory_iterator(myPath))
 *     cout << dirEntry << endl;
 *
 * As of C++17, std::filesystem is part of the standard library and
 * can be found in the <filesystem> header (no longer "experimental").
 *
 * Using Leptonica library:
 *
 * BOXA* bb = pixConnCompBB(pixb, 8); // to find bounding boxes of all connected components on the image
 * BOXA* bil = boxaIntersectsBox(bb, b);
 *
 * Cropping image with Leptonica:
 * (http://tpgit.github.io/Leptonica/croptext_8c_source.html)
 *
 * BOX* box = boxCreate(startX, startY, width, height);
 * PIX* pixd = pixClipRectangle(pixs, box, NULL);
 * boxDestroy(&box);
 *
 * and for PIX* there's
 *
 * pixDestroy(&pix);
 *
 * How to binarize image with Leptonica:
 * (https://tpgit.github.io/Leptonica/pixconv_8c_source.html)
 *
 * PIX *pixConvertTo1(PIX *pixs, l_int32 threshold);
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
    return false;
  }

  // Open input image with leptonica library
  // Pix *image = pixRead("./images/Paragraph.tif");
  Pix *image = pixRead(imagePath);

  if(image == NULL) {
    fprintf(stderr, "Could not read image: %s.\n", imagePath);
    api->End();
    return false;
  }

  Pix* pixb = pixConvertTo1(image, 128);
  BOXA* bb = pixConnCompBB(pixb, 8); // to find bounding boxes of all connected components on the image

  fprintf(stderr, "In %s found %d objects.\n", imagePath, bb->n);

  api->SetImage(image);

  // Get OCR result
  outText = api->GetUTF8Text();
    
  FILE *outFile;
  bool status = true;

  if((outFile = fopen(outPath,"w")) != NULL) {
    fprintf(outFile, "%s", outText);
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


#include <filesystem>
#include <iostream>
namespace fs = std::filesystem;


#if 0

// This image fails to be read by Leptonica!
int main()
{
  const char* language = "pus";
  const char* myPath = "./Ligatures/P2_719_2754.bmp";
  const char* outPath = "./Outputs/P2_719_2754.txt";  

  ocr(language, myPath, outPath);
}

#endif

int main()
{
  const char* language = "pus";
  const char* myPath = "./Ligatures/";

  using namespace std;

  for (auto& dirEntry : fs::directory_iterator(myPath)) {
    fs::path outPath("./Outputs/");
    outPath += dirEntry.path().stem();      
    outPath += ".txt";
    cout << dirEntry << "--->" << outPath.c_str() << endl;

    (void)ocr(language, dirEntry.path().c_str(), outPath.c_str());
  } 

  
}

