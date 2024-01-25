#include "SpdlogInit.hpp"

#include <iostream>
#include <mutex>

// #include <cpr/cpr.h>
#include <spdlog/async.h>
#include <spdlog/sinks/base_sink.h>
#include <spdlog/sinks/basic_file_sink.h>
#include <spdlog/sinks/stdout_sinks.h>
#include <spdlog/spdlog.h>

namespace
{
  template <typename Mutex>
  class discordImplSink : public spdlog::sinks::base_sink<Mutex>
  {
  public:
    explicit discordImplSink(std::string const& /*channel*/, std::string const& /*botToken*/)
    {
      // TODO: It would be nice at some point to set up a way to modify the logging channel
      // m_session.SetUrl(cpr::Url{"https://discord.com/api/v9/channels/" + channel + "/messages"});
      // m_session.SetHeader(cpr::Header{{"Authorization", "Bot " + botToken}});
    }

  private:
    // cpr::Session m_session;

  protected:
    void sink_it_(const spdlog::details::log_msg& msg) override
    {
      spdlog::memory_buf_t formatted;
      spdlog::sinks::base_sink<Mutex>::formatter_->format(msg, formatted);

      // m_session.SetPayload(cpr::Payload{{"content", fmt::to_string(formatted)}});
      // cpr::Response r = m_session.Post();

      // if (!std::stoi(r.header["x-ratelimit-remaining"]))
      // {
      //   auto resetAfter = std::stod(r.header["x-ratelimit-reset-after"]);
      //   std::this_thread::sleep_for(std::chrono::milliseconds(int(resetAfter * 1000)));
      // }
    }

    void flush_() override { std::cout << std::flush; }
  };
  using discordImplSink_mt = discordImplSink<std::mutex>;

  template <typename Mutex>
  class discord_sink : public spdlog::sinks::base_sink<Mutex>
  {
  public:
    // TRICKY: Because discord is rate-limited, it'll be slower than the other types of logging
    // and it needs its own worker thread. Utilizing a second logger will do the trick.
    explicit discord_sink(std::string const& channel, std::string const& botToken)
      : m_tp(std::make_shared<spdlog::details::thread_pool>(128, 1)),
        m_logger(std::make_shared<spdlog::async_logger>(
          "realDiscord",
          std::make_shared<discordImplSink_mt>(channel, botToken),
          m_tp,
          spdlog::async_overflow_policy::overrun_oldest))
    {
      spdlog::register_logger(m_logger);
      m_logger->set_pattern("%v");
    }

  private:
    std::shared_ptr<spdlog::details::thread_pool> m_tp;
    spdlog::details::async_logger_ptr m_logger;

  protected:
    void sink_it_(const spdlog::details::log_msg& msg) override
    {
      spdlog::memory_buf_t formatted;
      spdlog::sinks::base_sink<Mutex>::formatter_->format(msg, formatted);
      auto msgStr = fmt::to_string(formatted);
      std::vector<std::string> allStrs;
      // Discord has a content limit of 2000 characters. Splitting here means there won't have to be
      // loops in the impl sink
      while (msgStr.length() >= 2000)
      {
        // Since the message is already formatted and filtered with whatever log level was sent to
        // here, it doesn't matter what level we send this as.
        m_logger->info(msgStr.substr(0, 1990) + "```");
        msgStr = "```" + msgStr.substr(1991);
      }
      m_logger->info(msgStr);
    }

    void flush_() override { std::cout << std::flush; }
  };
  using discord_sink_mt = discord_sink<std::mutex>;
} // namespace

void utils::logging::init_spdlog(LogSettings logSettings)
{
  spdlog::init_thread_pool(100000, 1);
  auto pStdoutSink = std::make_shared<spdlog::sinks::stdout_sink_mt>();
  auto pFileSink = std::make_shared<spdlog::sinks::basic_file_sink_mt>("output.log");
  std::vector<spdlog::sink_ptr> sinks{pStdoutSink, pFileSink};
  auto logger =
    std::make_shared<spdlog::async_logger>("multiLogger",
                                           sinks.begin(),
                                           sinks.end(),
                                           spdlog::thread_pool(),
                                           spdlog::async_overflow_policy::overrun_oldest);
  spdlog::register_logger(logger);
  spdlog::set_default_logger(logger);

  // Setting the pattern overrides the pattern for all existing loggers.
  spdlog::set_pattern("[%m-%d %H:%M:%S.%f][%l]: %v");
  if (logSettings.optDiscordSettings)
  {
    auto pDiscordSink = std::make_shared<discord_sink_mt>(
      logSettings.optDiscordSettings->logChannel, logSettings.optDiscordSettings->botToken);
    pDiscordSink->set_pattern("```[%m-%d %H:%M:%S.%f][%l]\n%v```");
    logger->sinks().push_back(pDiscordSink);
  }
}
