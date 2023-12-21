#include "Utilities/SpdlogInit.hpp"
#include "SdCapnProto/echo.capnp.h"

#include <kj/debug.h>
#include <capnp/ez-rpc.h>
#include <capnp/message.h>
#include <iostream>

class EchoerImpl : public Echoer::Server {
public:
  kj::Promise<void> echo(EchoContext context) override {
    auto params = context.getParams();
    // std::cout << "Echoing: " << std::string(params.getMessage()) << std::endl;
    spdlog::info("Echoing: {}", std::string(params.getMessage()));
    return kj::READY_NOW;
  }
};

int main(/*int argc, char* argv[]*/)
{
  utils::logging::init_spdlog();
  try
  {
    spdlog::info("This is ReceiverMain");

    capnp::EzRpcServer server(kj::heap<EchoerImpl>(),"*:3456");
    kj::NEVER_DONE.wait(server.getWaitScope());
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
