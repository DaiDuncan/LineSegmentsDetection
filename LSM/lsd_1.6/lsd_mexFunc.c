/* dinggen 2022.08.27 Copyright (c) 2022  DAI Dinggen (dinggen.dai@student.kit.edu)
 */

/* mexFunction, Entry function to be used by matlab for compiling the c source code lsd.c
	Usage:
		lsd_scale(&n_out, double(img), X, Y, double(scale))
	INPUT:
        &n int, the number of the detected lines
		image <WxH>, double grey image
        X int, image width (column of matrix)
        Y int, image height (row of matrix)
        scale double, downsampling scale of image
	OUTPUT:
		lines <7xn>, x1,y1,x2,y2,width,p,-log10(NFA)
  */


#include "mex.h"
#include <stdio.h>
#include <stdlib.h>
#include "lsd.h"

/** deal with the index of image (Column major order in matlab) */
// #define INDEX(i,j,im) ((im)*(i)+(j))
#define NUM_OUTPUT_ROWS 7


void mexFunction(int nlhs, mxArray* plhs[], 
                 int nrhs, const mxArray* prhs[]) 
{
    unsigned int * n_out;
    double * image;
    double * output;
    double scale;
    unsigned int mrows,ncols;
    
    /* check the number of input arguments */
    if(nrhs != 3) {
        mexErrMsgIdAndTxt("lsd_scale(&n_out, double(image), double(scale))",
                          "Five inputs required.");
    }
    
    /* check the number of output arguments */
    if(nlhs != 1) {
        mexErrMsgIdAndTxt("(double)<7xn>: x1,y1,x2,y2,width,p,-log10(NFA)",
                          "One output required.");
    }
    
    /* validate the input arguments type */
    /* make sure the 2nd input argument is an image */
    mrows = mxGetM(prhs[1]);
    ncols = mxGetN(prhs[1]);
   
    if(!mxIsDouble(prhs[1]) ||
        mxIsComplex(prhs[1]) ||
        mrows <= 0 || ncols <= 0){
       mexErrMsgIdAndTxt( "2nd Input must be an image.");
    }
    
    /* get the values of input arguments */
    image = mxGetDoubles(prhs[1]);
    scale = mxGetScalar(prhs[2]);
    
    /* set the values to the ouput */
    output = lsd_scale(&n_out, image, scale);
    plhs[0] = mxCreateDoubleMatrix(mwSize(NUM_OUTPUT_ROWS), mwSize(n_out), mxREAL);
    *mxGetPr(plhs[0]) = output;
    
    /* free memory */
    free( (void *) image );
    free( (void *) output );

}

