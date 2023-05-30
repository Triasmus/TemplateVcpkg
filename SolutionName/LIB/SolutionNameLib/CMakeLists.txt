set(lib_name SolutionNameLib)
set(${lib_name}_srcs
  Helper.cpp
  Helper.hpp
  )
source_group("" FILES ${${lib_name}_srcs})
add_library(${lib_name} ${${lib_name}_srcs})
# target_link_libraries(${lib_name} PUBLIC )
target_include_directories(${lib_name} PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/../)
set_property(TARGET ${lib_name} PROPERTY FOLDER ${folder})
xpSourceListAppend(${${lib_name}_srcs})
