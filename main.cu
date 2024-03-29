#include "mpm3d.cuh"
#include <chrono>
#include <fmt/core.h>
#include <fstream>
#include <iostream>

#define USE_GUI// comment this line to disable gui
#ifdef USE_GUI

#include "gui.cuh"
#include <memory>
#include <thread>

constexpr int fps = 65;
constexpr auto frame_interval = std::chrono::nanoseconds(int(1e9)) / fps;

#endif

constexpr auto input_file_name = "../py/x_init";
constexpr auto output_file_name = "../py/x_cuda";

template<typename T>
struct fmt::formatter<
    T,
    std::enable_if_t<
        std::is_base_of_v<Eigen::DenseBase<T>, T>,
        char>> : ostream_formatter {
};

int main() {
#ifdef USE_GUI
  gui::init();
#endif
  using namespace std::chrono_literals;
  auto now = std::chrono::high_resolution_clock::now;

  std::shared_ptr<mpm::Vector[]> x_init = std::make_unique<mpm::Vector[]>(
      mpm::n_particles);
  auto ifs = std::ifstream(input_file_name);
  auto ofs = std::ofstream(output_file_name);

  for (auto i = 0; i < mpm::n_particles; i++) {
    for (auto j = 0; j < mpm::dim; j++) {
      ifs >> x_init[i][j];
    }
  }

  mpm::init(x_init);

  decltype(mpm::to_numpy()) x_cuda;
  auto start_time = now();
  for (auto runs = 0; runs < 2048; runs++) {
#ifdef USE_GUI
    auto frame_start = now();
#endif
    mpm::advance();
    x_cuda = mpm::to_numpy();
    auto x_copy = new std::remove_pointer_t<decltype(x_cuda)>[mpm::n_particles];
    for (auto i = 0; i < mpm::n_particles; i++) {
      x_copy[i] = x_cuda[i];
      x_cuda[i].array() += 0.000001;
    }
#ifdef USE_GUI
    gui::render(x_cuda);
    // limit fps
    auto rest_time = frame_interval - (now() - frame_start);
    if (rest_time.count() > 0) {
      std::this_thread::sleep_for(rest_time);// not very precise
    }
#endif
  }
  auto used_time = (now() - start_time) / 1ns;
  std::cout << double(used_time) / 1e9 << "s\n";

  for (auto i = 0; i < mpm::n_particles; i++) {
    fmt::print(ofs, "{}: [{}]\n", i, x_cuda[i].transpose());
  }
  return 0;
}
