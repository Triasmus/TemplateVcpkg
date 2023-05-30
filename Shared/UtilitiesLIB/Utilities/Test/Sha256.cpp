#include "Utilities/Sha256.hpp"

#include <boost/test/unit_test.hpp>

BOOST_AUTO_TEST_CASE(sha256)
{
  // Expected results from https://emn178.github.io/online-tools/sha256.html
  BOOST_CHECK_EQUAL(utils::crypto::sha256("test"),
                    "9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08");
  BOOST_CHECK_EQUAL(utils::crypto::sha256("alskdj"),
                    "a343e3cbcc72928a571778f77bf2554eb5b72c79ce28bbc9d3325c60c21e5241");
  BOOST_CHECK_EQUAL(
    utils::crypto::sha256("symbol=LTCBTC&side=BUY&type=LIMIT&timeInForce=GTC&quantity=1&"
                          "price=0.1&recvWindow=5000&timestamp=1499827319559"),
    "f791f81c95dd5d239891086cd0e4f8a587e471cade00bd333a78493831e01a9a");
}

BOOST_AUTO_TEST_CASE(hmacSha256)
{
  // From https://cryptobook.nakov.com/mac-and-key-derivation/hmac-and-key-derivation example
  BOOST_CHECK_EQUAL(utils::crypto::hmacSha256("sample message", "12345"),
                    "ee40ca7bc90df844d2f5b5667b27361a2350fad99352d8a6ce061c69e41e5d32");
  // From binance api docs example
  BOOST_CHECK_EQUAL(utils::crypto::hmacSha256(
                      "symbol=LTCBTC&side=BUY&type=LIMIT&timeInForce=GTC&quantity=1&price=0.1&"
                      "recvWindow=5000&timestamp=1499827319559",
                      "NhqPtmdSJYdKjVHjA7PZj4Mge3R5YNiP1e3UZjInClVN65XAbvqqM6A7H5fATj0j"),
                    "c8db56825ae71d6d79447849e617115f4a920fa2acdcab2b053c4b2838bd6b71");
}
