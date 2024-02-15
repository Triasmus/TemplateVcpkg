#include "Utilities/SpdlogInit.hpp"

int main(/*int argc, char* argv[]*/)
{
  utils::logging::init_spdlog();
  try
  {
    SPDLOG_INFO("This is SolutionNameMain");
  }
  catch (std::exception& e)
  {
    SPDLOG_ERROR("Exception: {}", e.what());
    spdlog::shutdown();
    return EXIT_FAILURE;
  }
  spdlog::shutdown();
  return EXIT_SUCCESS;
}
