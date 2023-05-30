set(exe_name Playground)
###############################################
set(${exe_name}_srcs
  main.cpp
  )
source_group("" FILES ${${exe_name}_srcs})
add_executable(${exe_name} ${${exe_name}_srcs})
###############################################
target_link_libraries(${exe_name}
  PUBLIC Utilities
  PRIVATE cpr::cpr Boost::json magic_enum::magic_enum
  )
set_property(TARGET ${exe_name} PROPERTY FOLDER ${folder})
install(TARGETS ${exe_name} DESTINATION bin)
