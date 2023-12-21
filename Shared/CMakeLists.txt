project(Shared VERSION ${CMAKE_PROJECT_VERSION})
set(folder ${PROJECT_NAME})
set_property(GLOBAL PROPERTY FOLDER ${PROJECT_NAME})
####################################################
set(InternalDirs # NOTE: ordered by dependency, then alphabetical
  SdCapnProtoLIB/SdCapnProto
  UtilitiesLIB/Utilities
  )
foreach(lib ${InternalDirs})
  add_subdirectory(${lib})
endforeach()
xpSourceListAppend()
