#ifndef UTILITIES_SPDLOG_INIT_HPP
#define UTILITIES_SPDLOG_INIT_HPP

#include <optional>

#include "spdlog/spdlog.h"

namespace utils::logging
{
  struct DiscordSettings
  {
    std::string logChannel;
    std::string botToken;
  };

  struct LogSettings
  {
    LogSettings() : optDiscordSettings(std::nullopt) { }
    LogSettings(DiscordSettings const& discSettings) : optDiscordSettings(discSettings) { }

    std::optional<DiscordSettings> optDiscordSettings;
  };

  void init_spdlog(LogSettings logSettings = LogSettings());
} // namespace utils::logging

#endif