#include "Utilities/SpdlogInit.hpp"

int main(/*int argc, char* argv[]*/)
{
  utils::logging::init_spdlog();
  spdlog::set_level(spdlog::level::trace);
  try
  {
    SPDLOG_INFO("Welcome to the Playground");
  }
  catch (std::exception& e)
  {
    SPDLOG_ERROR("Exception: {}", e.what());
  }
  spdlog::shutdown();
  return EXIT_SUCCESS;
}
