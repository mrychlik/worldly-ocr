#include "mex.h"
//#include <cassert>
/** 
 * A MEX wrapper around Tesseract 3
 * The function accepts these arguments (passed in array prhs):
 *    - An image, which must be a byte array (monochromatic)
 *
 * The output (passed to the caller in prhs[0]) is the Unicode
 * encoded text.
 * 
 * Explanations of arguments for MEX beginners below.
 *
 * @param nlhs              Number of left-hand sides.
 * @param plhs              Pointers to left-hand sides (must be allocated in the wrapper!).
 * @param nrhs              Number of right-hand sides passed as arguments.
 * @param prhs              Pointers to right-hand sides.
 * 
 */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  // This change required for Tesseract 4.0 (Marek Rychlik)
 // setlocale (LC_ALL, "C");


  if (nrhs < 1 || !mxIsUint8(prhs[0])) mexErrMsgTxt("Must call tessWrapper with the image to OCR.");

  char lang[16] = "chi_tra";	// Crashes with chi_tra_vert?

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
}