#include "Utilities/SpdlogInit.hpp"

int main()
{
  utils::logging::init_spdlog();
  spdlog::set_level(spdlog::level::trace);
  try
  {
    spdlog::info("Welcome to the Playground");
  }
  catch (std::exception& e)
  {
    spdlog::error("Exception: {}", e.what());
  }
  spdlog::shutdown();
  return EXIT_SUCCESS;
}
