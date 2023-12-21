#include <iostream>

#include <capnp/ez-rpc.h>
#include <capnp/message.h>
#include <kj/debug.h>

#include "SdCapnProto/stream.capnp.h"
#include "Utilities/SpdlogInit.hpp"

int main(/*int argc, char* argv[]*/)
{
  utils::logging::init_spdlog();
  try
  {
    spdlog::info("This is SenderMain");

    capnp::EzRpcClient client("localhost:3456");
    MyInterface::Client inter = client.getMain<MyInterface>();
    auto request = inter.streamingCallRequest();
    uint64_t count, size;
    std::cin >> count >> size;
    request.setCount(count);
    request.setSize(size);
    auto response = request.send().wait(client.getWaitScope());
    while (true)
    {
      response.
    }
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
