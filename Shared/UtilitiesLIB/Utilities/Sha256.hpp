#ifndef UTILITIES_SHA256_HPP
#define UTILITIES_SHA256_HPP

#include <string>

namespace utils::crypto
{
  std::string sha256(std::string const& input);

  std::string hmacSha256(std::string const& input, std::string const& key);

} // namespace utils::crypto

#endif
