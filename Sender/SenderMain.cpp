#include "Utilities/SpdlogInit.hpp"

int main(/*int argc, char* argv[]*/)
{
  utils::logging::init_spdlog();
  try
  {
    spdlog::info("This is SenderMain");
  }
  catch (std::exception& e)
  {
    spdlog::error("Exception: {}", e.what());
    spdlog::shutdown();
    return EXIT_FAILURE;
  }
  spdlog::shutdown();
  return EXIT_SUCCESS;
}
