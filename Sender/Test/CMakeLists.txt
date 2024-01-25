
set(exe_name SenderTest)
###############################################
set(${exe_name}_srcs
  SenderExampleTest.cpp
  )
source_group("" FILES ${${exe_name}_srcs})
###############################################
add_executable(${exe_name} ${${exe_name}_srcs})
target_link_libraries(${exe_name} PRIVATE GTest::gtest_main SenderLib)
set_property(TARGET ${exe_name} PROPERTY FOLDER UnitTests)
gtest_discover_tests(${exe_name})
xpSourceListAppend(${${exe_name}_srcs})
