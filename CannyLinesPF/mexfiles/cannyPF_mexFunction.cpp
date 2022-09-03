#include "mex.h"
#include "opencv_matlab.hpp"

#include <stdio.h>
#include <fstream>

#include "opencv2/opencv.hpp"
#include "opencv2/highgui.hpp"

// relative path to the lib directory
#include "lib/CannyPF.h"
#include "lib/ChainFromEdgeMap.h"

using namespace cv;
using namespace std;

class MexFunction : public matlab::mex::Function {
public:
    void operator()(matlab::mex::ArgumentList outputs, matlab::mex::ArgumentList inputs) {
        checkArguments(outputs, inputs);
        double multiplier = inputs[0][0];
        matlab::data::TypedArray<double> in = std::move(inputs[1]);
        arrayProduct(in, multiplier);
        outputs[0] = std::move(in);
    }

    void arrayProduct(matlab::data::TypedArray<double>& inMatrix, double multiplier) {
        
        for (auto& elem : inMatrix) {
            elem *= multiplier;
        }
    }

    void checkArguments(matlab::mex::ArgumentList outputs, matlab::mex::ArgumentList inputs) {
        std::shared_ptr<matlab::engine::MATLABEngine> matlabPtr = getEngine();
        matlab::data::ArrayFactory factory;

        if (inputs.size() != 2) {
            matlabPtr->feval(u"error", 
                0, std::vector<matlab::data::Array>({ factory.createScalar("Two inputs required") }));
        }

        if (inputs[0].getNumberOfElements() != 1) {
            matlabPtr->feval(u"error", 
                0, std::vector<matlab::data::Array>({ factory.createScalar("Input multiplier must be a scalar") }));
        }
        
        if (inputs[0].getType() != matlab::data::ArrayType::DOUBLE ||
            inputs[0].getType() == matlab::data::ArrayType::COMPLEX_DOUBLE) {
            matlabPtr->feval(u"error", 
                0, std::vector<matlab::data::Array>({ factory.createScalar("Input multiplier must be a noncomplex scalar double") }));
        }

        if (inputs[1].getType() != matlab::data::ArrayType::DOUBLE ||
            inputs[1].getType() == matlab::data::ArrayType::COMPLEX_DOUBLE) {
            matlabPtr->feval(u"error", 
                0, std::vector<matlab::data::Array>({ factory.createScalar("Input matrix must be type double") }));
        }

        if (inputs[1].getDimensions().size() != 2) {
            matlabPtr->feval(u"error", 
                0, std::vector<matlab::data::Array>({ factory.createScalar("Input must be m-by-n dimension") }));
        }
    }
};


// 
// 
// 
int main()
{
	string imgFile = "D:\\My_Data\\me_Projs\\Proj_MA\\CannyLines_PF4_CMake+cmake-gui\\data\\_origin.png";
	
    // 单通道
	cv::Mat img = cv::imread(imgFile, 0);
	printf("size of imaga %zu", sizeof(img));

	// get edge map
	CannyPF cannyer;
	cv::Mat edgeMap;
	float VMGradient = 70.0;
	cannyer.cannyPF( img, 3, VMGradient, edgeMap );

	// get edge chain
	ChainFromEdgeMap chainer;
	std::vector<std::vector<cv::Point> > edgeChains;
	chainer.run( img, edgeMap, edgeChains );

	// show  8bit single channel -> grayscale
    // imgShow is a cv::Mat data (not a function)
	cv::Mat imgShow( img.rows, img.cols, CV_8UC1, cv::Scalar( 0 ) );
	uchar* ptrS = (uchar*) imgShow.data;
	for ( int i=0; i<edgeChains.size(); ++i )
	{
		for ( int j=0; j<edgeChains[i].size(); ++j )
		{
			int loc = edgeChains[i][j].y * img.cols + edgeChains[i][j].x;
			ptrS[loc] = 255;  // choose white to show the edge
		}
	}
	cv::imwrite("D:\\My_Data\\me_Projs\\Proj_MA\\CannyLines_PF4_CMake+cmake-gui\\data\\cannyPF test1-simple.png",imgShow);
}
