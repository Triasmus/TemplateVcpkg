set(lib_name Utilities)
set(test_exe ${lib_name}Test)
###############################################
set(${lib_name}_srcs
  JsonSerializationHelpers.hpp
  SpdlogInit.cpp
  SpdlogInit.hpp
  Utility.cpp
  Utility.hpp
  )
source_group("" FILES ${${lib_name}_srcs})
list(APPEND ${lib_name}_libsrcs ${${lib_name}_srcs})
###############################################
set(${test_exe}_srcs
  Utility.test.cpp
  )
source_group("" FILES ${${test_exe}_srcs})
list(APPEND ${test_exe}_testsrcs ${${test_exe}_srcs})
###############################################
add_library(${lib_name} STATIC ${${lib_name}_libsrcs})
add_executable(${test_exe} ${${test_exe}_testsrcs})
# Link Libraries for sources ##################
target_link_libraries(${lib_name}
  PUBLIC Boost::json spdlog::spdlog
  PRIVATE
  )
# Link Libraries for tests ####################
target_link_libraries(${test_exe}
  PRIVATE ${lib_name} GTest::gtest_main
  )
###############################################
target_include_directories(${lib_name} PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/../)
set_property(TARGET ${lib_name} PROPERTY FOLDER ${lib_name})
set_property(TARGET ${test_exe} PROPERTY FOLDER ${lib_name})
gtest_discover_tests(${test_exe})
xpSourceListAppend(${${lib_name}_libsrcs} ${${test_exe}_testsrcs})
