cmake_minimum_required(VERSION 3.10)

project(FilterTest C)

set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED True)

include_directories(include)

add_executable(filter_test
	src/main.c
	src/filter.c
)
target_link_libraries(filter_test m)

