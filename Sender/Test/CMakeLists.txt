
set(exe_name SenderTest)
set(${exe_name}_srcs
  ExampleTest.cpp
  SenderMainTest.cpp
  )
source_group("" FILES ${${exe_name}_srcs})
add_executable(${exe_name} ${${exe_name}_srcs})
target_link_libraries(${exe_name} PRIVATE Boost::unit_test_framework SenderLib)
set_property(TARGET ${exe_name} PROPERTY FOLDER UnitTests)
add_test(NAME ${exe_name} COMMAND ${exe_name})
xpSourceListAppend(${${exe_name}_srcs})
