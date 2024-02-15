#include "Utility.hpp"

#include <gtest/gtest.h>

TEST(UtilitiesTest, Utility_getTimestamp_s)
{
  auto time = utils::getTimestamp_s();
  EXPECT_LT(time, 10000000000);
  EXPECT_GT(time, 1708015086);
}

TEST(UtilitiesTest, Utility_getTimestamp_ms)
{
  auto time = utils::getTimestamp_ms();
  EXPECT_LT(time, 10000000000000);
  EXPECT_GT(time, 1708015086000);
}
