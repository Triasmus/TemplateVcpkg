#include <boost/test/unit_test.hpp>

#include "ReceiverLib/Helper.hpp"

BOOST_AUTO_TEST_CASE(ExampleTest)
{
  BOOST_CHECK(helper::return_bool(true));
  BOOST_CHECK_EQUAL(helper::return_bool(false), false);
}
