
set(exe_name ${lib_name}Test)
set(${exe_name}_srcs
  UtilitiesExampleTest.cpp
  )
source_group("" FILES ${${exe_name}_srcs})
add_executable(${exe_name} ${${exe_name}_srcs})
target_link_libraries(${exe_name} PRIVATE GTest::gtest_main Utilities)
set_property(TARGET ${exe_name} PROPERTY FOLDER ${folder}/UnitTest)
gtest_discover_tests(${exe_name})
xpSourceListAppend(${${exe_name}_srcs})
