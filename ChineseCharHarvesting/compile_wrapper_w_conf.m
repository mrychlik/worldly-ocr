% setenv('LD_LIBRARY_PATH','/usr/local/lib');

mex -g -I/usr/local/include ...
     tessWrapperWithConfidence.cpp ...
    -L/usr/local/lib ...
    -ltesseract


     


