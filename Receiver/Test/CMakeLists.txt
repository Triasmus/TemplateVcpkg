
set(exe_name ReceiverTest)
###############################################
set(${exe_name}_srcs
  ReceiverExampleTest.cpp
  )
source_group("" FILES ${${exe_name}_srcs})
###############################################
add_executable(${exe_name} ${${exe_name}_srcs})
target_link_libraries(${exe_name} PRIVATE GTest::gtest_main ReceiverLib)
set_property(TARGET ${exe_name} PROPERTY FOLDER UnitTests)
gtest_discover_tests(${exe_name})
xpSourceListAppend(${${exe_name}_srcs})
