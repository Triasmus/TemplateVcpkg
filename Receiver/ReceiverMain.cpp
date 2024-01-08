#include <iostream>

#include <capnp/ez-rpc.h>
#include <capnp/message.h>
#include <kj/debug.h>

#include "SdCapnProto/echo.capnp.h"
#include "SdCapnProto/stream.capnp.h"
#include "Utilities/SpdlogInit.hpp"

#ifdef false
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
    auto test = promise.then([&callback]() { return callback.doneRequest().send(); });
    return test.wait(callback.)
    // spdlog::info("Echoing: {}", std::string(params.getMessage()));
    // return promise.then(req.send).then(kj::READY_NOW);
  }
};
#endif

class EchoerImpl : public Echoer::Server
{
public:
  kj::Promise<void> echo(EchoContext context) override
  {
    auto params = context.getParams();
    std::string req = params.getMessage();
    spdlog::info("Echoing: {}", req);
    context.getResults().setRes(req);
    return kj::READY_NOW;
  }
};

int main(/*int argc, char* argv[]*/)
{
  utils::logging::init_spdlog();
  try
  {
    spdlog::info("This is ReceiverMain");

    // capnp::EzRpcServer server(kj::heap<MyInterfaceImpl>(), "*:3456");
    capnp::EzRpcServer server(kj::heap<EchoerImpl>(), "*:3456");
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
