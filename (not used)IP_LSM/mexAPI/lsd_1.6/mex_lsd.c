/* dinggen 2022.08.27 Copyright (c) 2022  DAI Dinggen (dinggen.dai@student.kit.edu)
 */

/* mexFunction, Entry function to be used by matlab for compiling the c source code lsd.c
	Usage:
		lsd_scale(&n_out, double(img), X, Y, double(scale))
	INPUT:
		prhs[0]  image <WxH>, double grey image
        prhs[1]  scale double, downsampling scale of image
	OUTPUT:
		plhs[0]  lines <nx7>, x1,y1,x2,y2,width,p,-log10(NFA)
        plhs[1]  the number of detected lines
  */


#include "mex.h"

#include <stdio.h>
#include <stdlib.h>
#include "lsd.h"

/** deal with the index of image (Column major order in matlab) */
#define IDX(i,j,iSize) ((iSize)*(i)+(j))
#define OUT_MAT_COLS 7

/* Input Arguments */
#define IMAGE     prhs[0]
#define SCALE     prhs[1]

/* Output Arguments */
#define	OUT_MAT  	plhs[0]
#define	NUM_LINES	plhs[1]



void mexFunction(int nlhs, mxArray* plhs[], 
                 int nrhs, const mxArray* prhs[]) 
{
    double *image;
    double *output;
    double *M_in, *M_out;
    
    double scale;
    int num_lines=0;  // number of lines detected
    int i,j,mrows,ncols;
    
    
    /* check the number of input arguments */
    if(nrhs != 2) {
        mexErrMsgIdAndTxt("for lsd_scale(&n_out, (double *)image , ncols, mrows, (double)scale",
                          "2 inputs required: (double *)image, (double)scale");
    }
    /* check the number of output arguments */
    if(nlhs != 2) {
        mexErrMsgIdAndTxt("output matric <nx7>;   n_out: number of lines detected",
                          "two outputs required.");
    }
    
    /* validate the input arguments type */
    // make sure the 2nd input argument is an image
    scale = mxGetScalar(SCALE);
    mrows = mxGetM(IMAGE);
    ncols = mxGetN(IMAGE);
    mexPrintf("image rows is %u, image cols is %u\n",mrows, ncols);
    if(!mxIsDouble(IMAGE) ||
        mxIsComplex(IMAGE) ||
        mrows <= 0 || ncols <= 0){
       mexErrMsgIdAndTxt( "2nd Input must be an image.", 
                          "load an image");
    }
    
    /* get the values of input arguments */
    // create a pointer to the real data in the input matrix  
    #if MX_HAS_INTERLEAVED_COMPLEX
        M_in = mxGetDoubles(IMAGE);
    #else
        M_in = mxGetPr(IMAGE);
    #endif
        
    
    /* =========================== */
    /* call .c function */
    mexPrintf("hey I'm here 1 \n");
    mexPrintf("scale value is %f \n", scale);
    
    // from 2D-Matrix('M_in': column major order) to 1D-Array('image': row major order)
    // use the offset of pointer instead of using index (matlab begin from 1, and C begins from 0)
    // TODO: try to use mxMalloc() in matlab compiling env.  2022.08.29
    image = (double *) malloc( mrows * ncols * sizeof(double) );  // pointer should be specific
    if( image == NULL )
    {
      fprintf(stderr,"error: not enough memory \n");
      exit(EXIT_FAILURE);
    }
    
    
    for(i=0; i<mrows; ++i)
		for(j=0; j<ncols; ++j)
// 			*image++ = M_in[IDX(j,i,mrows)];  // can be deleted -> memory error because of ptr++
            image[i*ncols+j] = M_in[IDX(j,i,mrows)];
//             printf("%f ",image[i*ncols+j]);  // can be deleted
//         printf("\n");
    mexPrintf("hey I'm here 2 \n");
//     mexPrintf("the pixel of image is %ld \n", sizeof(image)/sizeof(double)); // can vbe deleted (image is a double pointer refers to 1D-array, so the output is only 1)
    
    // call lsd_scale()
    output = lsd_scale(&num_lines, image, ncols, mrows, scale);
    mexPrintf("number of detected lines is %d \n", num_lines);
    
    
    /* set the values to the ouput */
    NUM_LINES = mxCreateDoubleScalar(num_lines);
    OUT_MAT = mxCreateDoubleMatrix((mwSize)num_lines, (mwSize)OUT_MAT_COLS, mxREAL);
    /* create a pointer to the real data in the input matrix  */
    #if MX_HAS_INTERLEAVED_COMPLEX
        M_out = mxGetDoubles(OUT_MAT);
    #else
        M_out = mxGetPr(OUT_MAT);
    #endif
    mexPrintf("hey I'm here 3 \n");

    
    // from 1D-Array('output': row major order) in C to 2D-Matrix('M_out': column major order)
    for(i=0;i<num_lines;i++) 
		for(j=0;j<OUT_MAT_COLS;j++)
			M_out[IDX(j,i,num_lines)] = output[IDX(i,j,OUT_MAT_COLS)];
    mexPrintf("hey I'm here 4 \n");
          

    
    /* memcopy() */  
//     memcpy(mxGetPr(temp), data, 5*sizeof(double));   // can vbe deleted
    
    
    /* free memory */
    // TODO: try to use mxFree() in matlab compiling env.  2022.08.29

    free( (void *) image );
    free( (void *) output );

}

