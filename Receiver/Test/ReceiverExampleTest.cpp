#include <gtest/gtest.h>

#include "ReceiverLib/Helper.hpp"

TEST(ReceiverExampleTest, ReturnBool)
{
  EXPECT_TRUE(helper::return_bool(true));
  EXPECT_EQ(helper::return_bool(false), false);
}
