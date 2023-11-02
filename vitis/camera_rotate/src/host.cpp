#include <iostream>
#include <string>
#include <chrono>

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
	// Check the command line args
	if (argc < 3) {
	    std::cerr << "usage: camera_rotate <xclbin-file> <img>\n";
	    return EXIT_FAILURE;
	}

	// Define variables for time measurement
	auto start_time = std::chrono::high_resolution_clock::now();
	auto end_time = std::chrono::high_resolution_clock::now();

	//Define binary file and device index
    std::string binaryFile = argv[1];
    int device_index = 0; //Device index should be 0 on the Kria board

    // Define data size from args and vector size for buffers in byte
    int data_size = std::stoi(argv[2]);
    size_t vector_size_bytes = sizeof(int) * data_size;

    int error_flag = 0; //Error flag

    std::cout << "-------------------------------------------------------------------"<<std::endl;
    std::cout << "-- vadd host program                                             --"<<std::endl;
    std::cout << "-------------------------------------------------------------------"<<std::endl;

    //Open device
    auto device = xrt::device(device_index);

    //Get the kernel object from xclbin:
    //Load the xclbin file and get UUID.
    //The UUID is needed to open the kernel from the device.
    std::cout << "Load the xclbin: " << binaryFile << std::endl;
    auto uuid = device.load_xclbin(binaryFile);
    // Get some information on the device
    std::cout << "Device name: " << device.get_info<xrt::info::device::name>() << "\n";
    //Then get the kernel object from the UUID, "krnl_vadd" is the name of the kernel
    auto krnl = xrt::kernel(device, uuid, "krnl_vadd");

    // Allocate buffers for the kernel arguments with master interfaces in the
    // same memory bank as the kernel interfaces group id.
    // The group_id is the argument index of the HLS function.
    // The kernel has the following arguments (see HLS):
    // void krnl_vadd(Pixel *src_ptr, Pixel *dst_ptr, uint16_t rows, uint16_t cols,	uint8_t direction);
    // in1, in2 and out are master interfaces with memory buffers to be allocated.
    // size is a register in the kernel (slave interface) and needs no buffer.
    auto bo0 = xrt::bo(device, vector_size_bytes, krnl.group_id(0));
    auto bo1 = xrt::bo(device, vector_size_bytes, krnl.group_id(1));
    auto bo_out = xrt::bo(device, vector_size_bytes, krnl.group_id(2));

    // Do the data transfer between host and device by the buffer map API:
    // Map the host side backing pointer of the buffer to the user pointers,
    // then use the user pointers to fill the buffers with test data.
    auto bo0_map = bo0.map<int*>();
    auto bo1_map = bo1.map<int*>();
    auto bo_out_map = bo_out.map<int*>();
    // Create the test data and reference data
    int *bufReference = new int[data_size];
    for (int i = 0; i < data_size; ++i) {
        bo0_map[i] = i;
        bo1_map[i] = i;
        bo_out_map[i] = 0; //Fill output buffer with 0s
        bufReference[i] = bo0_map[i] + bo1_map[i];
    }

    // Transfer the host data to the device using the sync API
    START_MEASUREMENT
    bo0.sync(XCL_BO_SYNC_BO_TO_DEVICE);
    bo1.sync(XCL_BO_SYNC_BO_TO_DEVICE);
    END_MEASUREMENT(duration_trf1)

    //Execute the kernel: The signature (arguments) of the kernel execution
    //corresponds to the signature of the HLS code of the kernel.
    //The arguments 0-2 are the memory accesses via the buffers,
    //the argument 3 is a scalar argument (slave register).
	START_MEASUREMENT
    auto run = krnl(bo0, bo1, bo_out, data_size); //Start the kernel
    run.wait(); //Wait for completion of the kernel
    //Calculate execution time
    END_MEASUREMENT(duration_kernel)

    // Transfer device data to host using the sync API
	START_MEASUREMENT
    bo_out.sync(XCL_BO_SYNC_BO_FROM_DEVICE);
    END_MEASUREMENT(duration_trf2)

    // Compare device output data with the reference data
    for (int i = 0; i < data_size; ++i) {
    	if(bo_out_map[i] != bufReference[i]){
    		error_flag = 1;
    	}
    }

    // Final verdict
    std::cout << "-------------------------------------------------------------------"<<std::endl;
    if(error_flag == 1)
    	std::cout << "Test FAILED!" << std::endl;
    else
    	std::cout << "Test PASSED!" << std::endl;

    //Get some info on execution times
    std::cout << "-------------------------------------------------------------------"<<std::endl;
    std::cout << "Data size transferred (array size): " << data_size << std::endl;
	std::cout << "Execution time kernel: " << duration_kernel << " us" << std::endl;
	std::cout << "Transfer time to/from kernel memory: " << duration_trf1 << " us + " << duration_trf2
			<< " us =  "<< duration_trf1+duration_trf2 << " us" << std::endl;
    std::cout << "-------------------------------------------------------------------"<<std::endl;

    return 0;
}
