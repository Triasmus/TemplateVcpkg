#include <gtest/gtest.h>

#include "SolutionNameLib/Helper.hpp"

TEST(SolutionNameExampleTest, ReturnBool)
{
  EXPECT_TRUE(helper::return_bool(true));
  EXPECT_EQ(helper::return_bool(false), false);
}
