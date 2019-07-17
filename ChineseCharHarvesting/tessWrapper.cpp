/**
 * @file   tessWrapper.cpp
 * @author Marek Rychlik <marek@cannonball.lan>
 * @date   Tue Jul 16 20:15:37 2019
 * 
 * @brief  MEX wrapper around Tesseract 4.0
 * 
 * The original source is in: https://github.com/supersom/matlab-tesseract-ocr
 * However, the file is significantly modified in incompatible ways.
 * 
 * It turns out that only one line of code needs to be added, to compile
 * properly under Linux/GCC, which sets locale.
 *
 * Compile with:
 * 
 * mex -I/usr/local/include  tessWrapper.cpp  -L/usr/local/lib  -ltesseract
 *
 * This assumes that Tesseract 4 was installed from source in the
 * /usr/local tree which is the default. Tesseract 3 may exist in /usr
 * directory tree and there is no interference.
 *
 * Example usage from MATLAB:
 *
 *    [I, cmap] = imread('images/phototest.tif');
 *    % NOTE: Must transpose the image to work.
 *    J = uint8(I');
 *    tessWrapper(J)
 */

#include <tesseract/baseapi.h>
#include "mex.h"
#include <cassert>


/** 
 * A MEX wrapper around Tesseract 4
 * The function accepts these arguments (passed in array prhs):
 *    - An image, which must be a byte array (monochromatic)
 *
 * The output (passed to the caller in prhs[0]) is the Unicode
 * encoded text.
 * 
 * @param nlhs 
 * @param plhs 
 * @param nrhs 
 * @param prhs 
 * 
 */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  // This change required for Tesseract 4.0 (Marek Rychlik)
  setlocale (LC_ALL, "C");


  if (nrhs < 1 || !mxIsUint8(prhs[0])) mexErrMsgTxt("Must call tessWrapper with the image to OCR.");

  char lang[16] = "chi_tra";

  if (nrhs >= 2) {

    int len = mxGetM(prhs[1]) * mxGetN(prhs[1]);

    if (!mxIsChar(prhs[1])) {
      mexErrMsgTxt("You must specify the language as a string (typically 3 letters).");
    }

    if (len > 0) mxGetString(prhs[1],lang,sizeof(lang));
  }

  char tessbase[1024] = "/usr/share/tesseract/tessdata";//{0};

  if (nrhs >= 3) {
    mxGetString(prhs[2],tessbase,sizeof(tessbase));
  }

  tesseract::TessBaseAPI ocrApi;
  if (ocrApi.Init(tessbase, lang)) {

    mxArray *rhs[1], *lhs[1];
    char *path, *name;

    rhs[0] = mxCreateString("fullpath");
    mexCallMATLAB(1, lhs, 1, rhs, "mfilename");
    mxDestroyArray(rhs[0]);
    path = mxArrayToString(lhs[0]);
    mxDestroyArray(lhs[0]);

    if (ocrApi.Init(path, lang)) {
      mexWarnMsgTxt("Can not find language, defaulting to English.");
      if (ocrApi.Init(path, "eng")) {
	mexErrMsgTxt("error initializing tesseract");
      }
    }

    mxFree(path);
  }

  // This is the function used to pass an array
  // of bytes directly to the Tesseract engine.
  // We bypass Leptonica, no image file.
  //
  // From the documentation:
  // void tesseract::TessBaseAPI::SetImage(
  //            const   unsigned char *imagedata,
  // 		int  	width,
  // 		int  	height,
  // 		int  	bytes_per_pixel,
  // 		int  	bytes_per_line 
  // 	) 		
  //
  // Provide an image for Tesseract to recognize. Format is as
  // TesseractRect above. Does not copy the image buffer, or take
  // ownership. The source image may be destroyed after Recognize is
  // called, either explicitly or implicitly via one of the Get*Text
  // functions. SetImage clears all recognition results, and sets the
  // rectangle to the full image, so it may be followed immediately by a
  // GetUTF8Text, and it will automatically perform recognition.

  int width = mxGetM(prhs[0]);
  int height = mxGetN(prhs[0]);

  ocrApi.SetImage((unsigned char*)mxGetPr(prhs[0]),
		  width,
		  height,
		  1,
		  width);

  plhs[0] = mxCreateString(ocrApi.GetUTF8Text());

  ocrApi.End();
}
