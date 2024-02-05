
set(exe_name ${solution_name}Test)
###############################################
set(${exe_name}_srcs
  ${solution_name}ExampleTest.cpp
  )
source_group("" FILES ${${exe_name}_srcs})
###############################################
add_executable(${exe_name} ${${exe_name}_srcs})
target_link_libraries(${exe_name} PRIVATE GTest::gtest_main ${solution_name}Lib)
set_property(TARGET ${exe_name} PROPERTY FOLDER UnitTests)
gtest_discover_tests(${exe_name})
xpSourceListAppend(${${exe_name}_srcs})
