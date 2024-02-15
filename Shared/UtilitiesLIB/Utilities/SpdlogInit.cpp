#include "SpdlogInit.hpp"

#include <spdlog/async.h>
#include <spdlog/sinks/stdout_sinks.h>

void utils::logging::init_spdlog()
{
  spdlog::init_thread_pool(100000, 1);
  auto pStdoutSink = std::make_shared<spdlog::sinks::stdout_sink_mt>();
  auto logger =
    std::make_shared<spdlog::async_logger>("mainLogger",
                                           pStdoutSink,
                                           spdlog::thread_pool(),
                                           spdlog::async_overflow_policy::overrun_oldest);
  spdlog::register_logger(logger);
  spdlog::set_default_logger(logger);

  // Setting the pattern overrides the pattern for all existing loggers.
  spdlog::set_pattern("[%m-%d %H:%M:%S.%f][%l]: %v");
}
