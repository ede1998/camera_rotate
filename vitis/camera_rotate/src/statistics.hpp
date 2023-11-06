#pragma once

#include <algorithm>
#include <chrono>
#include <iostream>
#include <string>
#include <vector>

class Statistics {
	std::vector<std::pair<std::string, std::chrono::microseconds>> m_durations { };
	size_t m_data_size;
public:
	Statistics(size_t data_size) :
			m_data_size(data_size) {
	}

	void push_sum(std::string name, const std::string& first,
			const std::string& second) {
		auto search = [this](const std::string& needle) {
			return std::find_if(m_durations.begin(),
					m_durations.end(),
					[needle](auto elem) {return std::get<0>(elem) == needle;});
		};
		const auto first_pair = search(first);
		assert(first_pair != m_durations.end());
		const auto second_pair = search(second);
		assert(second_pair != m_durations.end());
		const auto first_duration = std::get<1>(*first_pair);
		const auto second_duration = std::get<1>(*second_pair);
		m_durations.emplace_back(name, first_duration + second_duration);
	}

	template <typename ResultT, typename FunctionT>
	ResultT time_this_result(std::string name, FunctionT func) {
		const auto start = std::chrono::high_resolution_clock::now();
		const auto result = func();
		const auto now = std::chrono::high_resolution_clock::now();
		const auto duration = std::chrono::duration_cast<
				std::chrono::microseconds>(now - start);
		m_durations.emplace_back(name, duration);
		return result;
	}

	template <typename FunctionT>
	void time_this(std::string name, FunctionT func) {
		const auto start = std::chrono::high_resolution_clock::now();
		func();
		const auto now = std::chrono::high_resolution_clock::now();
		const auto duration = std::chrono::duration_cast<
				std::chrono::microseconds>(now - start);
		m_durations.emplace_back(name, duration);
	}
	friend std::ostream& operator<<(std::ostream& os, const Statistics& stats);
};

std::ostream& operator<<(std::ostream& os, const Statistics& stats) {
	os
			<< "-------------------------------------------------------------------\n"
			<< "Data size transferred (array size): " << stats.m_data_size
			<< "\n";
	for (const auto& pair : stats.m_durations) {
		const auto& name = std::get<0>(pair);
		const auto& duration = std::get<1>(pair);
		os << name << ": " << duration.count() << "us" << "\n";
	}
	os << "-------------------------------------------------------------------";
	return os;
}
