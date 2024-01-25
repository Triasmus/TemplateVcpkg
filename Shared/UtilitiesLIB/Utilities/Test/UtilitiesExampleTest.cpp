#include <gtest/gtest.h>

// Demonstrate some basic assertions.
TEST(UtilitiesTest, BasicAssertions)
{
  // Expect two strings not to be equal.
  EXPECT_STRNE("hello", "world");
  // Expect equality.
  EXPECT_EQ(7 * 6, 42);
}

// Demonstrate some basic assertions.
TEST(UtilitiesTest, MoreBasicAssertions)
{
  // Expect two strings to be equal.
  EXPECT_STREQ("hello", "hello");
  // Expect equality.
  EXPECT_NE(7 * 6, 49);
}
