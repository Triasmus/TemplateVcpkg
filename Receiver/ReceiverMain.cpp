#include <iostream>

#include <capnp/ez-rpc.h>
#include <capnp/message.h>
#include <kj/debug.h>

#include "SdCapnProto/stream.capnp.h"
#include "Utilities/SpdlogInit.hpp"

class MyInterfaceImpl : public MyInterface::Server
{
public:
  kj::Promise<void> streamingCall(StreamingCallContext context) override
  {

    auto params = context.getParams();
    spdlog::info("received request. count: {}, size: {}", params.getCount(), params.getSize());

    auto callback = params.getCallback();
    auto sendChunk = [&callback, &params]()
    {
      auto req = callback.sendChunkRequest();
      req.setChunk(std::string(params.getSize(), 'b'));
      return req.send();
    };
    auto promise = sendChunk();
    for (uint64_t i = 0; i < params.getCount(); i++)
    {
      promise = promise.then(sendChunk);
    }
    return promise.then([&callback]() { return callback.doneRequest().send(); })
      .then([]() { return kj::READY_NOW; });
    // spdlog::info("Echoing: {}", std::string(params.getMessage()));
    // return promise.then(req.send).then(kj::READY_NOW);
  }
};

int main(/*int argc, char* argv[]*/)
{
  utils::logging::init_spdlog();
  try
  {
    spdlog::info("This is ReceiverMain");

    capnp::EzRpcServer server(kj::heap<MyInterfaceImpl>(), "*:3456");
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
