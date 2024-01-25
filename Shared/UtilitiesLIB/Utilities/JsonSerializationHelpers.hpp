#ifndef UTILITIES_JSONSERIALIZATIONHELPERS_HPP
#define UTILITIES_JSONSERIALIZATIONHELPERS_HPP

#include <boost/json.hpp>

#include <spdlog/spdlog.h>

namespace utils
{
  template <class T>
  void extract(boost::json::object const& obj, T& t, boost::json::string_view key)
  {
    if (obj.contains(key) && !obj.at(key).is_null())
      t = boost::json::value_to<T>(obj.at(key));
  }

  template <>
  inline void extract(boost::json::object const& obj, double& t, boost::json::string_view key)
  {
    if (obj.contains(key))
    {
      auto s = boost::json::value_to<std::string>(obj.at(key));
      if (!s.empty())
        t = std::stod(s);
    }
  }
} // namespace utils

#endif
