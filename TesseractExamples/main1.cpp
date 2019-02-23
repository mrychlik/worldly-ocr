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


int main()
{
    char *outText;

    tesseract::TessBaseAPI *api = new tesseract::TessBaseAPI();
    // Initialize tesseract-ocr with English, without specifying tessdata path
    if (api->Init(NULL, LANGUAGE)) {
        fprintf(stderr, "Could not initialize tesseract.\n");
        exit(1);
    }

    // Open input image with leptonica library
    // Pix *image = pixRead("/home/marek/Repos/Pashto/trunk/ReadingMicrofilm/images/Paragraph.tif");
    Pix *image = pixRead("./images/chinese-tradition-0pic.png");



    api->SetImage(image);
    // Get OCR result
    outText = api->GetUTF8Text();
    printf("OCR output:\n%s", outText);

    // Destroy used object and release memory
    api->End();
    delete [] outText;
    pixDestroy(&image);

    return 0;
}
