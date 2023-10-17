#include <iostream>

#include "krnl_vadd.h"

int main(){
	constexpr int TYPE_COLORIZED = 1;
	const auto in = xf::cv::imread("sample.jpg", TYPE_COLORIZED);
	Pixel out[in.rows][in.cols];

	krnl_vadd(&in.data, &out, in.rows, in.cols, 180);

	const auto out_mat = xf::cv::Mat(in.rows, in.cols, &out);

	xf::cv::imwrite("output_sample.jpg", out_mat);

//	std::cout << "-----------------------------"<<std::endl;
//	std::cout << "Tested "<<runSize<<" samples."<<std::endl;
//
//	if(error == 1){
//		std::cout<<"Test failed!"<<std::endl;
//		return 1;
//	}
//	else{
//		std::cout<<"Test passed!"<<std::endl;
//	}
//	std::cout << "-----------------------------"<<std::endl;
}
