#ifndef UTILITIES_JSONSERIALIZATIONHELPERS_HPP
#define UTILITIES_JSONSERIALIZATIONHELPERS_HPP

#include <boost/json.hpp>

#include <magic_enum.hpp>
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

  template <typename T>
  void extractEnum(boost::json::object const& obj, T& t, boost::json::string_view key)
  {
    if (obj.contains(key))
    {
      auto res = boost::json::value_to<std::string>(obj.at(key));
      auto optEnum = magic_enum::enum_cast<T>(res);
      if (optEnum.has_value())
        t = optEnum.value();
      else
        spdlog::error("Unknown {}: {}", typeid(T).name(), res);
    }
  }

  // Tricky: Although this is currently only being used for Binance OrderType, the templating is
  // hiding some fake errors from using magic_enum :D
  template <typename T>
  void extractEnum(boost::json::value const& val, T& t)
  {
    std::string res(val.as_string());
    auto optEnum = magic_enum::enum_cast<T>(res);
    if (optEnum.has_value())
      t = optEnum.value();
    else
      spdlog::error("Unknown {}: {}", typeid(T).name(), res);
  }
} // namespace utils

#endif
