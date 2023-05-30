#include "Utility.hpp"

#include <chrono>

namespace utils
{
  uint64_t getTimestamp_ms()
  {
    return std::chrono::duration_cast<std::chrono::milliseconds>(
             std::chrono::system_clock::now().time_since_epoch())
      .count();
  }

  uint64_t getTimestamp_s()
  {
    return std::chrono::duration_cast<std::chrono::seconds>(
             std::chrono::system_clock::now().time_since_epoch())
      .count();
  }

  uuids::uuid_random_generator makeUuidGenerator()
  {
    std::random_device rd;
    auto seed_data = std::array<int, std::mt19937::state_size>{};
    std::generate(std::begin(seed_data), std::end(seed_data), std::ref(rd));
    std::seed_seq seq(std::begin(seed_data), std::end(seed_data));
    std::mt19937 generator(seq);
    uuids::uuid_random_generator gen{generator};

    return gen;
  }
} // namespace utils