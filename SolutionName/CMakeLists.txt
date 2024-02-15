set(solution_name SolutionName)
set(exe_name ${solution_name})
add_subdirectory(LIB/${solution_name}Lib)
###############################################
set(${exe_name}_srcs
  ${exe_name}Main.cpp
  )
source_group("" FILES ${${exe_name}_srcs})
###############################################
add_executable(${exe_name} ${${exe_name}_srcs})
###############################################
target_link_libraries(${exe_name}
  PUBLIC ${exe_name}Lib
  PRIVATE Utilities
  )
set_property(TARGET ${exe_name} PROPERTY FOLDER ${exe_name})
install(TARGETS ${exe_name} DESTINATION bin)
xpSourceListAppend(${${exe_name}_srcs})
