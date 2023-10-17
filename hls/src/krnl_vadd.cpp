#include "krnl_vadd.h"

void krnl_vadd(Pixel *src_ptr, Pixel *dst_ptr, uint16_t rows, uint16_t cols,
		uint8_t direction) {
// AXI Lite Slave interface
#pragma HLS INTERFACE mode=s_axilite port=rows
#pragma HLS INTERFACE mode=s_axilite port=cols
#pragma HLS INTERFACE mode=s_axilite port=direction
#pragma HLS INTERFACE mode=s_axilite port=return
// AXI Master interfaces
#pragma HLS INTERFACE mode=m_axi depth=MAX_PIXELS port=src_ptr
#pragma HLS INTERFACE mode=m_axi depth=MAX_PIXELS port=dst_ptr

//#pragma HLS dataflow

//  xf::cv::Mat<TYPE8, MAX_HEIGHT, MAX_WIDTH, NPC> src(height, width);
//	xf::cv::Mat<TYPE8, MAX_HEIGHT, MAX_WIDTH, NPC> dst(height, width);

//  xf::cv::Array2xfMat<DATA_WIDTH, TYPE8, MAX_HEIGHT, MAX_WIDTH, NPC>(src_ptr, src);

	xf::cv::rotate(src_ptr, dst_ptr, rows, cols, direction);
//	xf::cv::xfMat2Array<DATA_WIDTH, TYPE8, MAX_HEIGHT, MAX_WIDTH, NPC>(dst, dst_ptr);

}

