#include <tesseract/baseapi.h>
#include <leptonica/allheaders.h>

//const char LANGUAGE[] = "eng";
//const char LANGUAGE[] = "chi_sim";


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
    Pix *image = pixRead("/home/marek/Repos/Pashto/trunk/Samples/Chinese/chinese-tra-testdata_1/chinese-tradition-0pic.png");



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
