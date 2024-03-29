#ifndef MPM3D_MPM3D_CUH
#define MPM3D_MPM3D_CUH

#include "Eigen/Dense"
#include "utils.h"
#include <cuda_runtime.h>
#include <fmt/core.h>
#include <fmt/ostream.h>
#include <memory>

namespace mpm {
using Real = float;
//using Real = double;

constexpr __device__ int dim = 3, n_grid = 32, steps = 25;
constexpr __device__ Real dt = 4e-4;

//constexpr __device__ int dim = 2, n_grid = 128, steps = 20;
//constexpr __device__ Real dt = 2e-4;

using Vector = std::conditional_t<std::is_same_v<Real, float>,
                                  std::conditional_t<
                                      dim == 2,
                                      Eigen::Vector2f,
                                      Eigen::Vector3f>,
                                  std::conditional_t<
                                      dim == 2,
                                      Eigen::Vector2d,
                                      Eigen::Vector3d>>;
using Matrix = std::conditional_t<std::is_same_v<Real, float>,
                                  std::conditional_t<
                                      dim == 2,
                                      Eigen::Matrix2f,
                                      Eigen::Matrix3f>,
                                  std::conditional_t<
                                      dim == 2,
                                      Eigen::Matrix2d,
                                      Eigen::Matrix3d>>;
using Vectori = std::conditional_t<
    dim == 2, Eigen::Vector2i, Eigen::Vector3i>;

constexpr __device__ int n_particles =
    utils::power(n_grid, dim) / utils::power(2, dim - 1);

void init(std::shared_ptr<mpm::Vector[]> = nullptr);

void advance();

Vector *to_numpy();// dummy
}// namespace mpm

#endif//MPM3D_MPM3D_CUH
