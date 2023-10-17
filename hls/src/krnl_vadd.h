#pragma once

#include <stdint.h>
#include <ap_int.h>

using Pixel = ap_uint<24>;
static constexpr uint64_t MAX_PIXELS =  3840 * 2160;

void krnl_vadd(Pixel *src_ptr, Pixel *dst_ptr, uint16_t rows, uint16_t cols,
		uint8_t direction);

