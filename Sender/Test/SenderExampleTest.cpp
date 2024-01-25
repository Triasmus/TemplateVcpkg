#include <gtest/gtest.h>

#include "SenderLib/Helper.hpp"

TEST(SenderExampleTest, ReturnBool)
{
  EXPECT_TRUE(helper::return_bool(true));
  EXPECT_EQ(helper::return_bool(false), false);
}
