
set(exe_name UtilitiesTest)
set(${exe_name}_srcs
  Sha256.cpp
  UtilitiesMainTest.cpp
  )
source_group("" FILES ${${exe_name}_srcs})
add_executable(${exe_name} ${${exe_name}_srcs})
target_link_libraries(${exe_name} PRIVATE Boost::unit_test_framework Utilities)
set_property(TARGET ${exe_name} PROPERTY FOLDER ${folder}/UnitTest)
add_test(NAME ${exe_name} COMMAND ${exe_name})
xpSourceListAppend(${${exe_name}_srcs})
