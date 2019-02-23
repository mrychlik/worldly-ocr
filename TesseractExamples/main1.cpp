/**
 * @file   main1.cpp
 * @author Marek Rychlik <marek@cannonball.lan>
 * @date   Fri Feb 22 19:48:12 2019
 * 
 * @brief  This example illustrates the use of Tesseract API.
 * 
 * 
 */


#include <tesseract/baseapi.h>
#include <leptonica/allheaders.h>

//const char LANGUAGE[] = "eng";
//const char LANGUAGE[] = "chi_sim";
const char LANGUAGE[] = "chi_tra";


int ocr(const char *const language, const char* const imagePath, const char *outPath)
{
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
    int status;

    if((outFile = fopen(outPath,"r")) != NULL) {
      fprintf(outFile, "OCR output for image %s:\n%s", imagePath, outText);
      fclose(outFile);
    } else {
      status = 1;
    }

    // Destroy used object and release memory
    api->End();
    delete [] outText;
    pixDestroy(&image);

    return status;
}


int main()
{
  // Open input image with leptonica library
  ocr("eng", "./images/Paragraph.tif", "./outputs/Paragraph.txt");
  ocr("chi_tra", "./images/chinese-tradition-0pic.png", "./outputs/chinese-tradition-0pic-chi_tra.txt");
}
