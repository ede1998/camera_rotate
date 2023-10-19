#include <iostream>

#include <common/xf_headers.hpp>
#include <common/xf_params.hpp>
#include <common/xf_sw_utils.hpp>
#include <opencv2/imgcodecs.hpp>

#include "krnl_vadd.h"

int main(){
	const auto in = cv::imread("/home/heneri/Dokumente/rslab/camera_rotate/hls/test.png", cv::IMREAD_COLOR);
	assert(in.channels() == BITS_PER_PIXEL / 8);
	assert(in.rows > 10);
	assert(in.cols > 10);
//	static_assert(sizeof(Pixel) == BITS_PER_PIXEL / 8);
	assert(in.data != nullptr && "Failed to load image");
	auto out_mat = cv::Mat(in.rows, in.cols, in.type());
	assert(out_mat.data != nullptr);

	const auto in_data = reinterpret_cast<Pixel*>(in.data);
	auto out_data = reinterpret_cast<Pixel*>(out_mat.data);

	krnl_vadd(in_data, out_data, in.rows, in.cols, 180);

	cv::imwrite("/home/heneri/Dokumente/rslab/camera_rotate/hls/output_test.png", out_mat);

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
