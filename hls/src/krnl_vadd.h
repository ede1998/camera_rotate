#pragma once

#include <stdint.h>
#include <ap_int.h>

static constexpr int BITS_PER_PIXEL = 8;
using Pixel = ap_uint<BITS_PER_PIXEL>;
static constexpr uint64_t MAX_ROWS = 512;//387;
static constexpr uint64_t MAX_COLS = 512;//687;

static constexpr uint64_t MAX_PIXELS = MAX_COLS * MAX_ROWS;

void krnl_vadd(Pixel *src_ptr, Pixel *dst_ptr, uint16_t rows, uint16_t cols,
		uint16_t direction);

