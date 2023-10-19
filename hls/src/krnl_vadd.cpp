#include "krnl_vadd.h"

#include <imgproc/xf_rotate.hpp>

static constexpr int __XF_DEPTH = (MAX_PIXELS * (XF_PIXELWIDTH(XF_8UC3, XF_NPPC1)) / 8) / (BITS_PER_PIXEL / 8);

void krnl_vadd(Pixel *src_ptr, Pixel *dst_ptr, uint16_t rows, uint16_t cols,
		uint8_t direction) {
// AXI Lite Slave interface
#pragma HLS INTERFACE mode=s_axilite port=rows
#pragma HLS INTERFACE mode=s_axilite port=cols
#pragma HLS INTERFACE mode=s_axilite port=direction
#pragma HLS INTERFACE mode=s_axilite port=return
// AXI Master interfaces
#pragma HLS INTERFACE mode=m_axi depth=__XF_DEPTH bundle=gmem0 port=src_ptr offset=slave
#pragma HLS INTERFACE mode=m_axi depth=__XF_DEPTH bundle=gmem1 port=dst_ptr offset=slave

//#pragma HLS dataflow


//  xf::cv::Mat<TYPE8, MAX_HEIGHT, MAX_WIDTH, NPC> src(height, width);
//	xf::cv::Mat<TYPE8, MAX_HEIGHT, MAX_WIDTH, NPC> dst(height, width);

//  xf::cv::Array2xfMat<DATA_WIDTH, TYPE8, MAX_HEIGHT, MAX_WIDTH, NPC>(src_ptr, src);

	xf::cv::rotate<BITS_PER_PIXEL, BITS_PER_PIXEL, XF_8UC3, 32, MAX_ROWS, MAX_COLS, XF_NPPC1>(src_ptr, dst_ptr, rows, cols, direction);
//	xf::cv::xfMat2Array<DATA_WIDTH, TYPE8, MAX_HEIGHT, MAX_WIDTH, NPC>(dst, dst_ptr);

}

