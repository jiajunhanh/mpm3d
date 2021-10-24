cmake_minimum_required(VERSION 3.20)
project(MPM3D CUDA)

set(CMAKE_CUDA_STANDARD 17)

add_executable(MPM3D main.cu mpm3d.cu)

set_target_properties(MPM3D PROPERTIES
        CUDA_SEPARABLE_COMPILATION ON
        CUDA_ARCHITECTURES 60)

target_compile_options(MPM3D PRIVATE $<$<COMPILE_LANGUAGE:CUDA>:
        --expt-relaxed-constexpr --diag-suppress 20236,20012>)

if (CMAKE_BUILD_TYPE EQUAL "RELEASE")
    target_compile_definitions(MPM3D PUBLIC EIGEN_NO_DEBUG)
endif (CMAKE_BUILD_TYPE EQUAL "RELEASE")