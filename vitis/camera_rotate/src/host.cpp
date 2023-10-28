#include <opencv2/core.hpp>
#include <opencv2/videoio.hpp>
#include <opencv2/highgui.hpp>
#include <iostream>
#include <stdio.h>

int main(int, char**) {
	cv::Mat frame;
	//--- INITIALIZE VIDEOCAPTURE
	cv::VideoCapture cap;
	// open the default camera using default API
	// cap.open(0);
	// OR advance usage: select any API backend
	int deviceID = 0; // 0 = open default camera
	int apiID = cv::CAP_ANY; // 0 = autodetect default API
	// open selected camera using selected API
	cap.open(deviceID, apiID);
	// check if we succeeded
	if (!cap.isOpened()) {
		std::cerr << "ERROR! Unable to open camera\n";
		return -1;
	}
	//--- GRAB AND WRITE LOOP
	std::cout << "Start grabbing" << std::endl << "Press any key to terminate"
			<< std::endl;
	for (;;) {
		// wait for a new frame from camera and store it into 'frame' and check if we succeeded
		if (!cap.read(frame)) {
			std::cerr << "ERROR! blank frame grabbed\n";
			break;
		}
		std::cout << "Image size: " << frame.cols << "x" << frame.rows
				<< ", depth: " << frame.depth() << ", channels: "
				<< frame.channels() << std::endl;
		// 1920x1080, CV_8U, 3
		// show live and wait for a key with timeout long enough to show images
		cv::imshow("Live", frame);
		if (cv::waitKey(5) >= 0) {
			break;
		}
	}
	// the camera will be deinitialized automatically in VideoCapture destructor
	return 0;
}
