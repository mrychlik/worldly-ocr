/**
 * @file   tessWrapper.cpp
 * @author Marek Rychlik <marek@cannonball.lan>
 * @date   Tue Jul 16 20:15:37 2019
 * 
 * @brief  MEX wrapper around Tesseract 4.0
 * 
 * 
 */

#include <tesseract/baseapi.h>
#include "mex.h"


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
        // This change required for Tesseract 4.0 (Marek Rychlik)
        setlocale (LC_ALL, "C");


	if (nrhs < 1 || !mxIsUint8(prhs[0])) mexErrMsgTxt("Must call tessWrapper with the image to OCR.");
//	if (nlhs != 1) mexErrMsgTxt("tessWrapper only returns one value: the ocr text");

	char lang[16] = "eng";
	if (nrhs >= 2) {
		int len = mxGetM(prhs[1])*mxGetN(prhs[1]);
		if (!mxIsChar(prhs[1])) mexErrMsgTxt("You must specify the language as a string (typically 3 letters).");

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

		if (ocrApi.Init(path, lang)) mexWarnMsgTxt("Can not find language, defaulting to English.");
		if (ocrApi.Init(path, "eng")) mexErrMsgTxt("error initializing tesseract");

		mxFree(path);
	}

	int width = mxGetM(prhs[0]);
	int height = mxGetN(prhs[0]);

	ocrApi.SetImage((unsigned char*)mxGetPr(prhs[0]), width, height, 1, width);

	plhs[0] = mxCreateString(ocrApi.GetUTF8Text());

	ocrApi.End();
}
