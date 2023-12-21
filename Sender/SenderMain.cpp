#include "Utilities/SpdlogInit.hpp"
#include "SdCapnProto/echo.capnp.h"

#include <kj/debug.h>
#include <capnp/ez-rpc.h>
#include <capnp/message.h>
#include <iostream>

int main(/*int argc, char* argv[]*/)
{
  utils::logging::init_spdlog();
  try
  {
    spdlog::info("This is SenderMain");

    capnp::EzRpcClient client("localhost:3456");
    Echoer::Client echoer = client.getMain<Echoer>();
    while(true){
      auto request = echoer.echoRequest();
      std::string toSend;
      std::cin >> toSend;
      request.setMessage(toSend);
      auto response = request.send().wait(client.getWaitScope());
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
