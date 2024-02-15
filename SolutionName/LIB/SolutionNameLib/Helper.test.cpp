#include "Helper.hpp"

#include <gtest/gtest.h>

TEST(SolutionNameTest, Helper_ReturnBool)
{
  EXPECT_TRUE(helper::return_bool(true));
  EXPECT_EQ(helper::return_bool(false), false);
}
