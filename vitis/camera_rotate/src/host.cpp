#include <atomic>
#include <chrono>
#include <iostream>
#include <string>
#include <thread>
#include <tuple>

#include <opencv2/core.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/videoio.hpp>

#define CPPHTTPLIB_OPENSSL_SUPPORT
#include "httplib.h"

#include "webpage.hpp"
#include "statistics.hpp"

// XRT includes
#include "xrt/xrt_bo.h"
#include "xrt/xrt_device.h"
#include "xrt/xrt_kernel.h"

int normalize(float rotation) {
	float zero_to_360 = fmod(rotation + 360.0, 360.0);
	const auto cardinal_direction = static_cast<int>(std::round(
			zero_to_360 / 90.0)) * 90;
	return (cardinal_direction == 360) ? 0 : cardinal_direction;
}

static std::atomic<float> current_rotation;

void run_rotation_server() {
	const std::string webpage { reinterpret_cast<char*>(___src_webpage_html),
			___src_webpage_html_len };
	httplib::SSLServer svr { "./certificate.pem", "./privatekey.pem" };

	svr.Get("/",
			[&webpage](const httplib::Request& req, httplib::Response& res) {
				res.set_content(webpage, "text/html");
			});

	svr.Get("/rotation",
			[](const httplib::Request& req, httplib::Response& res) {
				if (req.has_param("value")) {
					const auto rotation = std::stof(req.get_param_value("value"));
					current_rotation = rotation;
				}
			});

	std::cout << "Starting up server on https://0.0.0.0:1234" << std::endl;
	svr.listen("0.0.0.0", 1234);
}

cv::VideoCapture init_camera() {
	cv::VideoCapture cap;

	int deviceID = 0; // 0 = open default camera
	int apiID = cv::CAP_ANY; // 0 = autodetect default API

	cap.open(deviceID, apiID);
	if (!cap.isOpened()) {
		std::cerr << "ERROR! Unable to open camera\n";
		exit(1);
	}

	return cap;
}

std::tuple<xrt::bo, xrt::bo, xrt::kernel> init_fpga(
		const std::string& binaryFile, const size_t buffer_size) {
	int device_index = 0; //Device index should be 0 on the Kria board
	auto device = xrt::device(device_index);

	std::cout << "Load the xclbin: " << binaryFile << std::endl;
	const auto uuid = device.load_xclbin(binaryFile);
	std::cout << "Device name: " << device.get_info<xrt::info::device::name>()
			<< std::endl;
	auto krnl = xrt::kernel(device, uuid, "krnl_vadd");

	// Allocate buffers for the kernel arguments with master interfaces in the
	// same memory bank as the kernel interfaces group id.
	// The group_id is the argument index of the HLS function.
	// The kernel has the following arguments (see HLS):
	// void krnl_vadd(Pixel *src_ptr, Pixel *dst_ptr, uint16_t rows, uint16_t cols,	uint8_t direction);
	// src_ptr and dest_ptr are master interfaces with memory buffers to be allocated.
	// Others are registers in the kernel (slave interface) and needs no buffer.
	auto src = xrt::bo(device, buffer_size, krnl.group_id(0));
	auto dest = xrt::bo(device, buffer_size, krnl.group_id(1));

	return std::make_tuple(src, dest, krnl);
}

int main(int argc, char** argv) {
	if (argc < 2) {
		std::cerr << "usage: camera_rotate <xclbin-file>\n";
		return EXIT_FAILURE;
	}

	std::cout << "----------------------------------------------" << std::endl;
	std::cout << "-- camera_rotate host program               --" << std::endl;
	std::cout << "----------------------------------------------" << std::endl;

	auto cap = init_camera();

	constexpr size_t kRows = 1080;
	constexpr size_t kCols = 1920;

	constexpr size_t kRowsCropped = 512;
	constexpr size_t kColsCropped = 512;
	const auto image_size = kColsCropped * kRowsCropped * 1;

	auto tuple = init_fpga(argv[1], image_size);
	auto src = std::get<0>(tuple);
	auto dest = std::get<1>(tuple);
	auto krnl = std::get<2>(tuple);

	std::cout << "Start grabbing\nPress any key to terminate" << std::endl;
	cv::Mat frame(kRows, kCols, CV_8UC3);
	cv::Mat frame_bw(kRows, kCols, CV_8UC1);
	const cv::Rect cropArea((kCols - kColsCropped) / 2,
			(kRows - kRowsCropped) / 2, kColsCropped, kRowsCropped);

	std::thread web_server { run_rotation_server };

	for (;;) {
		Statistics stats { image_size };

		const auto frame_ok = stats.time_this_result<bool>("Capture frame",
				[&cap, &frame]() {
					return cap.read(frame);
				});

		if (!frame_ok) {
			std::cerr << "ERROR! blank frame grabbed\n";
			break;
		}

		assert(frame.cols == kCols);
		assert(frame.rows == kRows);
		assert(frame.type() == CV_8UC3);
		assert(frame.isContinuous());

		stats.time_this("Convert to BW", [&frame, &frame_bw]() {
			cv::cvtColor(frame, frame_bw, cv::COLOR_BGR2GRAY);
		});

		const auto frame_cropped = cv::Mat(frame_bw, cropArea).clone();
		assert(frame_cropped.rows > 10);
		assert(frame_cropped.cols > 10);
		assert(frame_cropped.type() == CV_8UC1);
		assert(frame_cropped.channels() == 1);
		assert(frame_cropped.isContinuous());

		assert(frame_cropped.total() * frame_cropped.elemSize() == image_size);
		src.write(frame_cropped.data);

		stats.time_this("Transfer to kernel", [&src]() {
			src.sync(XCL_BO_SYNC_BO_TO_DEVICE);
		});

		const auto rotation = normalize(current_rotation);
		stats.set_rotation(rotation);

		stats.time_this("Kernel execution", [&]() {
			auto run = krnl(src, dest, frame_cropped.rows, frame_cropped.cols,
					rotation);
			run.wait();
		});

		stats.time_this("Transfer from kernel", [&src]() {
			src.sync(XCL_BO_SYNC_BO_FROM_DEVICE);
		});

		stats.push_sum("Total transfer time", "Transfer from kernel",
				"Transfer to kernel");

		std::cout << stats << std::endl;

		const auto rotated_image = cv::Mat(frame_cropped.rows,
				frame_cropped.cols, frame_cropped.type(), dest.map());

		// show live and wait for a key with timeout long enough to show images
		cv::imshow("Live", rotated_image);
		if (cv::waitKey(5) >= 0) {
			break;
		}
	}

	web_server.join();

	return 0;
}
