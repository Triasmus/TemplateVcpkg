#ifndef UTILITIES_UTILITY_HPP
#define UTILITIES_UTILITY_HPP

#include <cstdint>

#include <stduuid/uuid.h>

namespace utils
{
  uint64_t getTimestamp_s();
  uint64_t getTimestamp_ms();

  uuids::uuid_random_generator makeUuidGenerator();
} // namespace utils

#endif