/* Description
 *
 *  In C++:
 *      1 cannyer.cannyPF(image, GaussSize, VMGradient, edgeMap);
 *          get `edgeMap` by using canny filter
 *      2 chainer.run(image, edgeMap, edgeChains);
 *          get edge chains based on `edgeMap`
 *
 *  In Matlab:
 *      inputs[0]: grayscale image (double)
 *      inputs[1]: gaussian kernel size (odd uint8 scalar)
 *      inputs[2]: VMGradient (double scalar)
 *      
 *      outputs[0]: edgeMap (the same size as input grayscale image)
 *      outputs[1]: edgeChains (std::vector< std::vector<cv::Point> >   several edgeChains, each is composed of a set of points)
 *
 * Author: Dinggen DAI (daidinggen@hotmail.com)
 * Date: 2022.08
 */
#include <stdio.h>
#include <fstream>

#include "mex.hpp"
#include "mexAdapter.hpp"  // matlab API for C++
#include "opencv2/opencv.hpp"

// relative path to the lib directory
#include "../include/CannyPF.h"
#include "../include/ChainFromEdgeMap.h"

#define IDX(i,j,iSize) ((iSize)*(i)+(j))

using namespace cv;
using namespace std;
using namespace matlab::data;
using matlab::mex::ArgumentList;


class MexFunction : public matlab::mex::Function {
    // Pointer to MATLAB engine to call fprintf
    std::shared_ptr<matlab::engine::MATLABEngine> matlabPtr = getEngine();

    // Factory to create MATLAB data arrays
    ArrayFactory factory;

    // Create an output stream
    std::ostringstream stream;
public:
    void operator()(ArgumentList outputs, ArgumentList inputs) {
        checkArguments(outputs, inputs);
        
//         stream << "hey I'm here 0:" << std::endl; displayOnMATLAB(stream);
        /* 1 determine input image properties  */
        matlab::data::ArrayDimensions dims = inputs[0].getDimensions(); 
        
        const size_t nDims      = dims.size();  //dims is a vector
        const size_t rows       = dims[0]; 
        const size_t cols       = dims[1];
        const size_t channels = (nDims == 3 ? dims[2] : 1);
        int i, j;
        stream << "This is a " << channels << " channel(s)' image"  << std::endl; displayOnMATLAB(stream);
        stream << "hey I'm here 1. " << "Image size (rows, cols): (" << rows << " ," << cols << ")"  << std::endl; displayOnMATLAB(stream);
        
        /* 2 Data type convertion: from Matlab to C++  */
        // Allocate, copy, and convert the input image
        // @note: input[0] is double image -> OpenCV Canny() requires 8-bit input image
        cv::Mat image(cv::Size( (int)cols, (int)rows ), CV_8UC1, Scalar(1));
        stream << "Image size is -> " << image.size().height << ", " << image.size().width << std::endl; displayOnMATLAB(stream);
        
        const size_t num_eles = inputs[0].getNumberOfElements();
        stream << "hey I'm here 2. Number of elements  " << num_eles << std::endl; displayOnMATLAB(stream);

        const TypedArray<double> imageArray = std::move(inputs[0]);   // Issue: inputs[0] from Matlab needs to the same double type, otherwise, Can't convert the Array(uint8s) to this TypedArray
//         stream << "hey I'm here 2+. Print the (0, 0) element in OpenCV format" << image.at<uchar>(0, 0) + 1  <<  std::endl; displayOnMATLAB(stream);
//         stream << "hey I'm here 2++. Print the (0, 0) element in Matlab Array format: "<< imageArray[0][0] <<  ", Print the last element in Matlab Array format: " << imageArray[rows-1][cols-1]   << std::endl; displayOnMATLAB(stream);

        for(i=0; i<rows; ++i)
            for(j=0; j<cols; ++j)
                image.at<uchar>(i, j) = (int) (imageArray[i][j] * 255);  // from matlab(column major order (row, col)) to C++(row major order (col, row)) 
        
        /* 3 run c++ module  */
        const unsigned int GaussSize = inputs[1][0];
        const float VMGradient = (float)inputs[2][0];
        CannyPF cannyer;
        cv::Mat edgeMap;
        
        // in C++: get edge map by using canny filter
        cannyer.cannyPF(image, GaussSize, VMGradient, edgeMap);
        // in C++: get edge chains
        ChainFromEdgeMap chainer;
        std::vector< std::vector<cv::Point> > edgeChains;
        chainer.run(image, edgeMap, edgeChains);
        
        /* 4 determine output image properties */
        // @note: outputs[0] is uint8 edge map
        // force it row major order as in OpenCV, C/C++
        const int output_rows = edgeMap.rows;
        const int output_cols = edgeMap.cols;
        uint8_t *edgePtr = edgeMap.data;
        outputs[0] = factory.createArray<uint8_t> ({(size_t)output_rows, (size_t)output_cols});  // the pixel value is 0-255
       
        stream << "hey I'm here 3. EdgeChains.size is " << edgeChains.size() << std::endl; displayOnMATLAB(stream);     
        /* 5 Data type convertion: from c++ to Matlab */
//         for(i=0; i<output_rows; ++i)
//             for(j=0; j<output_cols; ++j){
//                 if (i==output_rows-1 && j==output_cols-1) break;
//                 outputs[0][i][j] = *edgePtr++; // attention: ++ operator -> memory overflow
//             }
//         outputs[0][output_rows-1][output_cols-1] = *edgePtr;
        for(i=0; i<output_rows; ++i)
            for(j=0; j<output_cols; ++j){
                outputs[0][i][j] = *edgePtr++; // attention: ++ operator -> memory overflow
            }

        stream << "hey I'm here 4. The rows and cols of output is " << output_rows << " and " << output_cols <<  std::endl; displayOnMATLAB(stream); 
        /* outputs[1] */
        CellArray allEdges = factory.createCellArray ({edgeChains.size(), size_t(1)});
        stream << "hey I'm here 4+. The size of outputs[1] is " << allEdges.getDimensions()[0] << " and " << allEdges.getDimensions()[1]  <<  std::endl; displayOnMATLAB(stream);
        
        size_t singleEdgeSize;
        for(i=0; i<edgeChains.size(); ++i){
            singleEdgeSize = edgeChains[i].size();
            allEdges[i] = factory.createArray<int> ({singleEdgeSize, size_t(2)}) ;  // the pixel coordinate value is around 3,000  ChainFromEdgeMap.cpp  cv::Point<int>
            TypedArrayRef<int> singleEdge = allEdges[i][0];

            for(j=0; j<singleEdgeSize; ++j){
                // matlab Topic: Access C++ Data Array Container Elements -> Copy Data from Container -> ref book: matlab::data::Reference<TypedArray<T>>
                singleEdge[j][0] = edgeChains[i][j].x;
                singleEdge[j][1] = edgeChains[i][j].y;
            }
        }
                 
        stream << "hey I'm OK!" << std::endl; displayOnMATLAB(stream);
        outputs[1] = std::move(allEdges); 
    }


private:
    void displayOnMATLAB(std::ostringstream& stream) {
        // Pass stream content to MATLAB fprintf function
        matlabPtr->feval(u"fprintf", 0,
            std::vector<Array>({ factory.createScalar(stream.str()) }));
        // Clear stream buffer
        stream.str("");
    }

    void checkArguments(ArgumentList outputs, ArgumentList inputs) {
        std::shared_ptr<matlab::engine::MATLABEngine> matlabPtr = getEngine();
        ArrayFactory factory;
        
        /* check inputs */
        if (inputs.size() != 3) {
            matlabPtr->feval(u"error", 
                0, std::vector<Array>({ factory.createScalar("Thress inputs required") }));
        }
        
        // inputs[0] is double grayscale image
        if (inputs[0].getType() != ArrayType::DOUBLE ||
            inputs[0].getType() == ArrayType::COMPLEX_DOUBLE) {
            matlabPtr->feval(u"error", 
                0, std::vector<Array>({ factory.createScalar("Input[0] image must be type DOUBLE") }));
        }
        
        if (inputs[0].getDimensions().size() != 2) {
            matlabPtr->feval(u"error", 
                0, std::vector<Array>({ factory.createScalar("Input[0] image must be m-by-n dimension") }));
        }
        
        if (inputs[1].getNumberOfElements() != 1) {
            matlabPtr->feval(u"error", 
                0, std::vector<Array>({ factory.createScalar("Input[1] gaussian kernel size must be a scalar") }));
        }
        
        const unsigned char gauss_size = inputs[1][0];
        if (inputs[1].getType() != ArrayType::UINT8 ||
            inputs[1].getType() == ArrayType::COMPLEX_UINT8 ||
            gauss_size % 2 == 0) {
            matlabPtr->feval(u"error", 
                0, std::vector<Array>({ factory.createScalar("Input[1] gaussian kernel size must be a noncomplex scalar odd UINT8") }));
        }
        
        if (inputs[2].getNumberOfElements() != 1) {
            matlabPtr->feval(u"error", 
                0, std::vector<Array>({ factory.createScalar("Input[2] VMGradient must be a scalar") }));
        }
        
        if (inputs[2].getType() != ArrayType::DOUBLE ||
            inputs[2].getType() == ArrayType::COMPLEX_DOUBLE) {
            matlabPtr->feval(u"error", 
                0, std::vector<Array>({ factory.createScalar("Input[2] VMGradient must be a noncomplex scalar double") }));
        }
        
        
        // check outputs
        if (outputs.size() != 2) {
            matlabPtr->feval(u"error", 
                0, std::vector<Array>({ factory.createScalar("Two outputs required") }));
        }
        
    }
};

