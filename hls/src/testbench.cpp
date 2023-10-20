#include <iostream>
#include <string>


#include <common/xf_headers.hpp>
#include <common/xf_params.hpp>
#include <common/xf_sw_utils.hpp>
#include <opencv2/imgcodecs.hpp>

#include "krnl_vadd.h"

int main(){
	const std::string hls_folder = "../../../../";

	const auto in = cv::imread(hls_folder + "test.png", cv::IMREAD_GRAYSCALE);
	const auto reference = cv::imread(hls_folder + "ref_test.png", cv::IMREAD_GRAYSCALE);

	assert(in.channels() == BITS_PER_PIXEL / 8);
	assert(in.rows > 10);
	assert(in.cols > 10);
	static_assert(sizeof(Pixel) == BITS_PER_PIXEL / 8);
	assert(in.data != nullptr && "Failed to load image");
	auto out_mat = cv::Mat(in.rows, in.cols, in.type());
	assert(out_mat.data != nullptr);

	const auto in_data = reinterpret_cast<Pixel*>(in.data);
	auto out_data = reinterpret_cast<Pixel*>(out_mat.data);

	krnl_vadd(in_data, out_data, in.rows, in.cols, 180);

	cv::imwrite(hls_folder + "output_test.png", out_mat);

	cv::Mat diff;
    // Compute absolute difference image
    cv::absdiff(out_mat, reference, diff);
    // Save the difference image
    cv::imwrite(hls_folder + "diff.png", diff);

    float err_per;
    xf::cv::analyzeDiff(diff, 0, err_per);

    if (err_per > 0.0f) {
        fprintf(stderr, "ERROR: Test Failed.\n ");
        return 1;
    }
    std::cout << "Test Passed " << std::endl;
	return 0;
}
