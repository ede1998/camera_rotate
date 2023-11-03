#include <iostream>
#include <string>
#include <chrono>

#include <opencv2/core.hpp>
#include <opencv2/videoio.hpp>
#include <opencv2/highgui.hpp>

// XRT includes
#include "xrt/xrt_bo.h"
#include "xrt/xrt_device.h"
#include "xrt/xrt_kernel.h"

// Makros for time measurements
#define START_MEASUREMENT start_time = std::chrono::high_resolution_clock::now();
#define END_MEASUREMENT(var) 	end_time = std::chrono::high_resolution_clock::now(); \
		auto var = std::chrono::duration_cast<std::chrono::microseconds>(end_time \
		- start_time).count();

int main(int argc, char** argv) {
	if (argc < 3) {
		std::cerr << "usage: camera_rotate <xclbin-file> <img>\n";
		return EXIT_FAILURE;
	}

	std::chrono::high_resolution_clock::time_point start_time, end_time;

	std::string binaryFile = argv[1];
	int device_index = 0; //Device index should be 0 on the Kria board

	std::cout << "----------------------------------------------" << std::endl;
	std::cout << "-- camera_rotate host program               --" << std::endl;
	std::cout << "----------------------------------------------" << std::endl;

	auto device = xrt::device(device_index);

	std::cout << "Load the xclbin: " << binaryFile << std::endl;
	const auto uuid = device.load_xclbin(binaryFile);
	std::cout << "Device name: " << device.get_info<xrt::info::device::name>()
			<< "\n";
	auto krnl = xrt::kernel(device, uuid, "krnl_vadd");

	const auto image = cv::imread(argv[2], cv::IMREAD_GRAYSCALE);
	assert(image.rows > 10);
	assert(image.cols > 10);
	assert(image.type() == CV_8UC1);
	assert(image.channels() == 1);
	assert(image.isContinuous());

	const auto image_size = image.total() * image.elemSize();

	// Allocate buffers for the kernel arguments with master interfaces in the
	// same memory bank as the kernel interfaces group id.
	// The group_id is the argument index of the HLS function.
	// The kernel has the following arguments (see HLS):
	// void krnl_vadd(Pixel *src_ptr, Pixel *dst_ptr, uint16_t rows, uint16_t cols,	uint8_t direction);
	// src_ptr and dest_ptr are master interfaces with memory buffers to be allocated.
	// Others are registers in the kernel (slave interface) and needs no buffer.
	auto src = xrt::bo(device, image_size, krnl.group_id(0));
	auto dest = xrt::bo(device, image_size, krnl.group_id(1));

	src.write(image.data);

	// Transfer the host data to the device using the sync API
	START_MEASUREMENT
	src.sync(XCL_BO_SYNC_BO_TO_DEVICE);
	END_MEASUREMENT(duration_trf1)

	START_MEASUREMENT
	auto run = krnl(src, dest, image.rows, image.cols, 90);
	run.wait();
	END_MEASUREMENT(duration_kernel)

	// Transfer device data to host using the sync API
	START_MEASUREMENT
	dest.sync(XCL_BO_SYNC_BO_FROM_DEVICE);
	END_MEASUREMENT(duration_trf2)

	const auto rotated_image = cv::Mat(image.rows, image.cols, image.type(),
			dest.map());
	//Get some info on execution times
	std::cout
			<< "-------------------------------------------------------------------"
			<< std::endl;
	std::cout << "Data size transferred (array size): " << image_size
			<< std::endl;
	std::cout << "Execution time kernel: " << duration_kernel << " us"
			<< std::endl;
	std::cout << "Transfer time to/from kernel memory: " << duration_trf1
			<< " us + " << duration_trf2 << " us =  "
			<< duration_trf1 + duration_trf2 << " us" << std::endl;
	std::cout
			<< "-------------------------------------------------------------------"
			<< std::endl;

	cv::imshow("Rotated", rotated_image);
	cv::waitKey(1000);
	return 0;
}
